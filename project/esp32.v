`timescale 1ns / 1ps

module esp32 (
    input wire clk,
    input wire trigger,
    input wire [1:0] msg_type, // 1 = WARN, 2 = SOS, 3 = RESET
    output reg tx_start,
    output reg [7:0] tx_data,
    input wire tx_busy
);

    reg [2:0] state = 0;
    reg [2:0] char_idx = 0;
    reg [1:0] latched_msg = 0;
    
    always @(posedge clk) begin
        tx_start <= 0;
        
        case (state)
            0: begin 
                if (trigger) begin 
                    latched_msg <= msg_type;
                    state <= 1; 
                    char_idx <= 0; 
                end
            end
            1: begin 
                if (!tx_busy && !tx_start) begin
                    // Send "WARN\n"
                    if (latched_msg == 2'd1) begin
                        case (char_idx)
                            0: tx_data <= "W"; 1: tx_data <= "A"; 2: tx_data <= "R"; 3: tx_data <= "N"; 4: tx_data <= 8'h0A;
                        endcase
                        if (char_idx == 4) state <= 2; else begin tx_start <= 1; char_idx <= char_idx + 1; end
                    end 
                    // Send "SOS\n"
                    else if (latched_msg == 2'd2) begin
                        case (char_idx)
                            0: tx_data <= "S"; 1: tx_data <= "O"; 2: tx_data <= "S"; 3: tx_data <= 8'h0A;
                        endcase
                        if (char_idx == 3) state <= 2; else begin tx_start <= 1; char_idx <= char_idx + 1; end
                    end
                    // Send "RESET\n"
                    else if (latched_msg == 2'd3) begin
                        case (char_idx)
                            0: tx_data <= "R"; 1: tx_data <= "E"; 2: tx_data <= "S"; 3: tx_data <= "E"; 4: tx_data <= "T"; 5: tx_data <= 8'h0A;
                        endcase
                        if (char_idx == 5) state <= 2; else begin tx_start <= 1; char_idx <= char_idx + 1; end
                    end
                    else begin
                        state <= 2; // Failsafe
                    end
                end
            end
            2: begin 
                if (!trigger) state <= 0; // Wait for trigger to drop
            end
        endcase
    end
endmodule