`timescale 1ns / 1ps

module imu_controller(
    input wire clk,
    input wire reset,
    inout wire sda,
    inout wire scl,
    output reg [15:0] gyro_x,
    output reg [15:0] gyro_y,
    output reg [15:0] gyro_z,
    output reg data_ready
);

    // I2C timing: 24MHz / 120 = 200kHz tick. 
    // Since each bit takes 4 ticks, SCL runs at a safe 50kHz.
    reg [6:0] clk_div;
    reg i2c_tick;
    always @(posedge clk) begin
        if (clk_div == 119) begin 
            clk_div <= 0; 
            i2c_tick <= 1; 
        end else begin 
            clk_div <= clk_div + 1; 
            i2c_tick <= 0; 
        end
    end

    reg [1:0] phase;
    reg [3:0] bit_cnt;
    reg [7:0] tx_data;
    reg [47:0] rx_buffer;
    reg [3:0] byte_cnt;

    // Open-drain driver logic
    reg sda_r, scl_r;
    assign sda = (sda_r == 1'b0) ? 1'b0 : 1'bz;
    assign scl = (scl_r == 1'b0) ? 1'b0 : 1'bz;

    // FSM States
    localparam S_BOOT_DELAY  = 0;
    localparam S_IDLE        = 1;
    localparam S_WAKE_START  = 2;
    localparam S_WAKE_ADDR   = 3;
    localparam S_WAKE_REG    = 4;
    localparam S_WAKE_DATA   = 5;
    localparam S_WAKE_STOP   = 6;
    localparam S_READ_START1 = 7;
    localparam S_READ_ADDR1  = 8;
    localparam S_READ_REG    = 9;
    localparam S_READ_START2 = 10;
    localparam S_READ_ADDR2  = 11;
    localparam S_READ_DATA   = 12;
    localparam S_READ_STOP   = 13;

    reg [4:0] state;
    reg initialized;
    reg [15:0] boot_delay; // 16-bit counter for startup delay

    always @(posedge clk) begin
        if (reset) begin
            state <= S_BOOT_DELAY;
            sda_r <= 1; scl_r <= 1;
            phase <= 0; bit_cnt <= 0;
            boot_delay <= 0; initialized <= 0;
            data_ready <= 0;
        end else if (i2c_tick) begin
            case (state)
                // Wait ~327ms for MPU-6050 to power on properly
                S_BOOT_DELAY: begin
                    if (boot_delay == 16'hFFFF) state <= S_IDLE;
                    else boot_delay <= boot_delay + 1;
                end
                
                S_IDLE: begin
                    sda_r <= 1; scl_r <= 1; phase <= 0; bit_cnt <= 0; data_ready <= 0;
                    if (!initialized) state <= S_WAKE_START;
                    else state <= S_READ_START1;
                end
                
                // ----------------------------------------------------
                // 1. Wake Up Sequence (Write 0x00 to Register 0x6B)
                // ----------------------------------------------------
                S_WAKE_START: begin
                    if (phase == 0) begin sda_r <= 1; scl_r <= 1; phase <= 1; end
                    else if (phase == 1) begin sda_r <= 0; scl_r <= 1; phase <= 2; end
                    else if (phase == 2) begin sda_r <= 0; scl_r <= 0; phase <= 0; tx_data <= 8'hD0; state <= S_WAKE_ADDR; end
                end
                S_WAKE_ADDR: begin
                    if (phase == 0) begin sda_r <= (bit_cnt < 8) ? tx_data[7-bit_cnt] : 1'b1; phase <= 1; end 
                    else if (phase == 1) begin scl_r <= 1; phase <= 2; end 
                    else if (phase == 2) begin phase <= 3; end // Wait for slave to ACK
                    else if (phase == 3) begin
                        scl_r <= 0; phase <= 0;
                        if (bit_cnt == 8) begin bit_cnt <= 0; tx_data <= 8'h6B; state <= S_WAKE_REG; end
                        else bit_cnt <= bit_cnt + 1;
                    end
                end
                S_WAKE_REG: begin
                    if (phase == 0) begin sda_r <= (bit_cnt < 8) ? tx_data[7-bit_cnt] : 1'b1; phase <= 1; end
                    else if (phase == 1) begin scl_r <= 1; phase <= 2; end
                    else if (phase == 2) begin phase <= 3; end
                    else if (phase == 3) begin
                        scl_r <= 0; phase <= 0;
                        if (bit_cnt == 8) begin bit_cnt <= 0; tx_data <= 8'h00; state <= S_WAKE_DATA; end
                        else bit_cnt <= bit_cnt + 1;
                    end
                end
                S_WAKE_DATA: begin
                    if (phase == 0) begin sda_r <= (bit_cnt < 8) ? tx_data[7-bit_cnt] : 1'b1; phase <= 1; end
                    else if (phase == 1) begin scl_r <= 1; phase <= 2; end
                    else if (phase == 2) begin phase <= 3; end
                    else if (phase == 3) begin
                        scl_r <= 0; phase <= 0;
                        if (bit_cnt == 8) begin bit_cnt <= 0; state <= S_WAKE_STOP; end
                        else bit_cnt <= bit_cnt + 1;
                    end
                end
                S_WAKE_STOP: begin
                    if (phase == 0) begin sda_r <= 0; scl_r <= 0; phase <= 1; end
                    else if (phase == 1) begin scl_r <= 1; phase <= 2; end
                    else if (phase == 2) begin sda_r <= 1; phase <= 3; end
                    else if (phase == 3) begin initialized <= 1; state <= S_IDLE; end
                end

                // ----------------------------------------------------
                // 2. Read Sequence (Read 6 bytes starting at 0x43)
                // ----------------------------------------------------
                S_READ_START1: begin
                    if (phase == 0) begin sda_r <= 1; scl_r <= 1; phase <= 1; end
                    else if (phase == 1) begin sda_r <= 0; scl_r <= 1; phase <= 2; end
                    else if (phase == 2) begin sda_r <= 0; scl_r <= 0; phase <= 0; tx_data <= 8'hD0; state <= S_READ_ADDR1; end
                end
                S_READ_ADDR1: begin
                    if (phase == 0) begin sda_r <= (bit_cnt < 8) ? tx_data[7-bit_cnt] : 1'b1; phase <= 1; end
                    else if (phase == 1) begin scl_r <= 1; phase <= 2; end
                    else if (phase == 2) begin phase <= 3; end
                    else if (phase == 3) begin
                        scl_r <= 0; phase <= 0;
                        if (bit_cnt == 8) begin bit_cnt <= 0; tx_data <= 8'h43; state <= S_READ_REG; end
                        else bit_cnt <= bit_cnt + 1;
                    end
                end
                S_READ_REG: begin
                    if (phase == 0) begin sda_r <= (bit_cnt < 8) ? tx_data[7-bit_cnt] : 1'b1; phase <= 1; end
                    else if (phase == 1) begin scl_r <= 1; phase <= 2; end
                    else if (phase == 2) begin phase <= 3; end
                    else if (phase == 3) begin
                        scl_r <= 0; phase <= 0;
                        if (bit_cnt == 8) begin bit_cnt <= 0; state <= S_READ_START2; end
                        else bit_cnt <= bit_cnt + 1;
                    end
                end
                S_READ_START2: begin
                    if (phase == 0) begin sda_r <= 1; scl_r <= 0; phase <= 1; end
                    else if (phase == 1) begin scl_r <= 1; phase <= 2; end
                    else if (phase == 2) begin sda_r <= 0; scl_r <= 1; phase <= 3; end
                    else if (phase == 3) begin sda_r <= 0; scl_r <= 0; phase <= 0; tx_data <= 8'hD1; state <= S_READ_ADDR2; end
                end
                S_READ_ADDR2: begin
                    if (phase == 0) begin sda_r <= (bit_cnt < 8) ? tx_data[7-bit_cnt] : 1'b1; phase <= 1; end
                    else if (phase == 1) begin scl_r <= 1; phase <= 2; end
                    else if (phase == 2) begin phase <= 3; end
                    else if (phase == 3) begin
                        scl_r <= 0; phase <= 0;
                        if (bit_cnt == 8) begin bit_cnt <= 0; byte_cnt <= 0; state <= S_READ_DATA; end
                        else bit_cnt <= bit_cnt + 1;
                    end
                end
                S_READ_DATA: begin
                    // Phase 0: If we are on the ACK/NACK bit (bit 8), pull SDA low to ACK, or leave high to NACK.
                    if (phase == 0) begin sda_r <= (bit_cnt == 8) ? (byte_cnt == 5 ? 1'b1 : 1'b0) : 1'b1; phase <= 1; end
                    else if (phase == 1) begin scl_r <= 1; phase <= 2; end
                    else if (phase == 2) begin 
                        // Phase 2: SCL is High, safe to sample data
                        if (bit_cnt < 8) rx_buffer[47 - {byte_cnt, 3'b000} - bit_cnt] <= sda; 
                        phase <= 3; 
                    end
                    else if (phase == 3) begin
                        scl_r <= 0; phase <= 0;
                        if (bit_cnt == 8) begin
                            bit_cnt <= 0;
                            if (byte_cnt == 5) state <= S_READ_STOP;
                            else byte_cnt <= byte_cnt + 1;
                        end else bit_cnt <= bit_cnt + 1;
                    end
                end
                S_READ_STOP: begin
                    if (phase == 0) begin sda_r <= 0; scl_r <= 0; phase <= 1; end
                    else if (phase == 1) begin scl_r <= 1; phase <= 2; end
                    else if (phase == 2) begin 
                        sda_r <= 1; phase <= 3; 
                        gyro_x <= rx_buffer[47:32];
                        gyro_y <= rx_buffer[31:16];
                        gyro_z <= rx_buffer[15:0];
                        data_ready <= 1;
                    end
                    else if (phase == 3) begin data_ready <= 0; state <= S_IDLE; end
                end
            endcase
        end else begin
            data_ready <= 0;
        end
    end
endmodule