`timescale 1ns / 1ps

module top (
    input wire clk_24mhz,
    inout wire sda,
    inout wire scl,
    input wire key_0,       // Pin A13 (Manual Reset)
    output wire led1,       // Pin D5  (X-Axis Positive Spike)
    output wire led2,       // Pin A3  (X-Axis Negative Spike)
    output wire led3,       // Pin B4  (Y-Axis Positive Spike)
    output wire led4,       // Pin A4  (Y-Axis Negative Spike)
    output wire seg_din,    // Pin J15
    output wire seg_cs,     // Pin J16
    output wire seg_clk,    // Pin H12
    output wire buzzer,     // Pin K5
    output wire esp32_tx    // Pin T3 (PMOD J16) -> Connects to ESP32 RX
);

    // =========================================================
    // 1. SENSOR INPUTS & EXPLICIT SIGNED MATH
    // =========================================================
    wire reset = 0;
    wire [15:0] gyro_x, gyro_y, gyro_z;
    wire data_ready;

    imu_controller mpu_inst (
        .clk(clk_24mhz), .reset(reset), .sda(sda), .scl(scl),
        .gyro_x(gyro_x), .gyro_y(gyro_y), .gyro_z(gyro_z),
        .data_ready(data_ready)
    );

    wire signed [15:0] sx = gyro_x;
    wire signed [15:0] sy = gyro_y;

    wire [15:0] abs_x = (sx < 0) ? -sx : sx;
    wire [15:0] abs_y = (sy < 0) ? -sy : sy;

    // THE RECALIBRATED BOUNDARY: 15,000
    localparam [15:0] BOUNDARY = 16'd15000; 

    wire x_out_of_bounds = (abs_x > BOUNDARY);
    wire y_out_of_bounds = (abs_y > BOUNDARY);

    assign led1 = (sx >  16'd15000);
    assign led2 = (sx < -16'd15000);
    assign led3 = (sy >  16'd15000);
    assign led4 = (sy < -16'd15000);

    // 10ms Timebase for accurate real-world timers
    reg [17:0] tick_counter = 0;
    reg tick_10ms = 0;
    always @(posedge clk_24mhz) begin
        if (tick_counter >= 240000 - 1) begin
            tick_counter <= 0;
            tick_10ms <= 1;
        end else begin
            tick_10ms <= 0;
            tick_counter <= tick_counter + 1;
        end
    end

    // =========================================================
    // 2. THE STRICT BOUNDARY STATE MACHINE
    // =========================================================
    reg [1:0] sys_state = 2'd0; // 0: G00d, 1: bAd, 2: SOS
    reg [7:0] x_timer = 0;      
    reg [7:0] y_timer = 0;      

    wire sys_reset = ~key_0; 

    always @(posedge clk_24mhz) begin
        // MANUAL OVERRIDE (Key 0 clears everything back to G00d)
        if (sys_reset) begin
            sys_state <= 2'd0;
            x_timer <= 0;
            y_timer <= 0;
        end else if (tick_10ms) begin
            
            // NORMAL STATE -> WARNING STATE
            if (sys_state == 2'd0) begin
                if (x_out_of_bounds || y_out_of_bounds) begin
                    sys_state <= 2'd1; // Latch instantly onto 'bAd'
                end
            end
            
            // WARNING STATE (Latched) -> CRITICAL SOS
            else if (sys_state == 2'd1) begin
                
                // RULE 3: X-Axis 2-Second Timer
                if (x_out_of_bounds) begin
                    if (x_timer >= 8'd200) sys_state <= 2'd2; // SOS!
                    else x_timer <= x_timer + 1;
                end else begin
                    x_timer <= 0; // BOUNDARY ENFORCED: Inside the zone, timer drops to 0.
                end

                // RULE 4: Y-Axis 1-Second Timer
                if (y_out_of_bounds) begin
                    if (y_timer >= 8'd100) sys_state <= 2'd2; // SOS!
                    else y_timer <= y_timer + 1;
                end else begin
                    y_timer <= 0; // BOUNDARY ENFORCED: Inside the zone, timer drops to 0.
                end
            end
        end
    end

    // =========================================================
    // 3. MAX7219 7-SEGMENT DISPLAY CONTROLLER
    // =========================================================
    reg [4:0] seg_tick_div = 0;
    wire      seg_tick = (seg_tick_div == 23);

    always @(posedge clk_24mhz) begin
        if (seg_tick) seg_tick_div <= 0;
        else seg_tick_div <= seg_tick_div + 1;
    end

    reg [5:0]  seg_state = 0;
    reg [15:0] seg_shift = 0;
    reg [2:0]  curr_dig  = 0;
    reg [15:0] word_to_send;

    always @(*) begin
        case (curr_dig)
            3'd0: word_to_send = 16'h0C01; 
            3'd1: word_to_send = 16'h0900; 
            3'd2: word_to_send = 16'h0A07; 
            3'd3: word_to_send = 16'h0B03; 
            3'd4: begin 
                if (sys_state == 2'd2)      word_to_send = {8'h01, 8'h5B}; // S
                else if (sys_state == 2'd1) word_to_send = {8'h01, 8'h1F}; // b
                else                        word_to_send = {8'h01, 8'h5E}; // G
            end
            3'd5: begin 
                if (sys_state == 2'd2)      word_to_send = {8'h02, 8'h7E}; // O
                else if (sys_state == 2'd1) word_to_send = {8'h02, 8'h77}; // A
                else                        word_to_send = {8'h02, 8'h7E}; // 0
            end
            3'd6: begin 
                if (sys_state == 2'd2)      word_to_send = {8'h03, 8'h5B}; // S
                else if (sys_state == 2'd1) word_to_send = {8'h03, 8'h3D}; // d
                else                        word_to_send = {8'h03, 8'h7E}; // 0
            end
            3'd7: begin 
                if (sys_state == 2'd2)      word_to_send = {8'h04, 8'h00}; // Blank
                else if (sys_state == 2'd1) word_to_send = {8'h04, 8'h00}; // Blank
                else                        word_to_send = {8'h04, 8'h3D}; // d
            end
            default: word_to_send = 16'h0000;
        endcase
    end

    reg seg_din_r = 0, seg_cs_r = 1, seg_clk_r = 0;
    assign seg_din = seg_din_r;
    assign seg_cs = seg_cs_r;
    assign seg_clk = seg_clk_r;

    always @(posedge clk_24mhz) begin
        if (seg_tick) begin
            if (seg_state == 0) begin
                seg_cs_r <= 0; seg_clk_r <= 0; seg_shift <= word_to_send; seg_state <= 1;
            end else if (seg_state <= 32) begin
                if (seg_state[0]) begin seg_din_r <= seg_shift[15]; seg_clk_r <= 0; end 
                else begin seg_clk_r <= 1; seg_shift <= {seg_shift[14:0], 1'b0}; end
                seg_state <= seg_state + 1;
            end else begin
                seg_cs_r <= 1; seg_clk_r <= 0;
                if (curr_dig < 7) curr_dig <= curr_dig + 1;
                else curr_dig <= 3'd4; 
                seg_state <= 0;
            end
        end
    end

    // ==========================================
    // 4. CRITICAL STATE (MORSE CODE BUZZER)
    // ==========================================
    wire buzzer_trigger = (sys_state == 2'd2); 

    reg [12:0] tone_counter = 0;
    reg buzzer_wave = 0;

    always @(posedge clk_24mhz) begin
        if (tone_counter >= 5999) begin
            tone_counter <= 0;
            buzzer_wave <= ~buzzer_wave;
        end else tone_counter <= tone_counter + 1;
    end

    localparam DOT_CYCLES = 3600000; 
    localparam [33:0] SOS_PATTERN = 34'b10101_000_11101110111_000_10101_0000000;
    
    reg [21:0] dot_timer = 0;
    reg [5:0] seq_index = 33;

    always @(posedge clk_24mhz) begin
        if (!buzzer_trigger) begin
            dot_timer <= 0;
            seq_index <= 33;
        end else begin
            if (dot_timer >= DOT_CYCLES - 1) begin
                dot_timer <= 0;
                if (seq_index == 0) seq_index <= 33;
                else seq_index <= seq_index - 1;
            end else dot_timer <= dot_timer + 1;
        end
    end

    assign buzzer = buzzer_trigger ? (buzzer_wave & SOS_PATTERN[seq_index]) : 1'b0;

    // =========================================================
    // 5. ESP32 UART & FIREBASE TRIGGER LOGIC
    // =========================================================
    reg [1:0] prev_state = 0;
    reg reset_prev = 0;
    reg esp_trigger = 0;
    reg [1:0] esp_msg = 0;

    always @(posedge clk_24mhz) begin
        prev_state <= sys_state;
        reset_prev <= sys_reset;
        esp_trigger <= 0; 

        if (sys_state == 2'd1 && prev_state == 2'd0) begin
            esp_trigger <= 1; esp_msg <= 2'd1; // Trigger "WARN"
        end 
        else if (sys_state == 2'd2 && prev_state != 2'd2) begin
            esp_trigger <= 1; esp_msg <= 2'd2; // Trigger "SOS"
        end 
        else if (sys_reset && !reset_prev) begin
            esp_trigger <= 1; esp_msg <= 2'd3; // Trigger "RESET"
        end
    end

    wire tx_start;
    wire [7:0] tx_data;
    wire tx_busy;

    esp32 esp_inst (
        .clk(clk_24mhz),
        .trigger(esp_trigger),
        .msg_type(esp_msg),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_busy(tx_busy)
    );

    uart_sender uart_inst (
        .clk(clk_24mhz),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_busy(tx_busy),
        .tx_out(esp32_tx)
    );

endmodule