`timescale 1ns / 1ps

module uart_sender (
    input wire clk, // 24 MHz
    input wire tx_start,
    input wire [7:0] tx_data,
    output reg tx_busy,
    output reg tx_out
);

    // 24,000,000 / 115200 = ~208 clock cycles per bit
    localparam CLK_PER_BIT = 208;
    
    reg [2:0] state = 0;
    reg [7:0] data_reg = 0;
    reg [15:0] clk_count = 0;
    reg [2:0] bit_index = 0;

    always @(posedge clk) begin
        case (state)
            0: begin // IDLE
                tx_out <= 1'b1;
                tx_busy <= 0;
                clk_count <= 0;
                if (tx_start) begin
                    data_reg <= tx_data;
                    tx_busy <= 1'b1;
                    state <= 1; // START
                end
            end
            1: begin // START BIT
                tx_out <= 1'b0;
                if (clk_count < CLK_PER_BIT - 1) clk_count <= clk_count + 1;
                else begin clk_count <= 0; state <= 2; bit_index <= 0; end
            end
            2: begin // DATA BITS
                tx_out <= data_reg[bit_index];
                if (clk_count < CLK_PER_BIT - 1) clk_count <= clk_count + 1;
                else begin
                    clk_count <= 0;
                    if (bit_index < 7) bit_index <= bit_index + 1;
                    else state <= 3;
                end
            end
            3: begin // STOP BIT
                tx_out <= 1'b1;
                if (clk_count < CLK_PER_BIT - 1) clk_count <= clk_count + 1;
                else begin clk_count <= 0; state <= 0; end
            end
        endcase
    end
endmodule