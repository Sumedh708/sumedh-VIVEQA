`timescale 1ns / 1ps
module fsm_2(
    input clk,
    input [1:0] din,
    input rst,
    output reg [1:0] op
);

parameter S0 = 2'b00,
          S1 = 2'b01,
          S2 = 2'b10,
          S3 = 2'b11;

reg [1:0] state, next_state;


always @(posedge clk) begin
    if (rst)
        state <= S0;
    else
        state <= next_state;
end
always @(*) begin
    next_state = state;
    op         = state;

    case(state)

        S0: begin
            if      (din == 2'b00) begin next_state = S0; op = 2'b00; end
            else if (din == 2'b01) begin next_state = S1; op = 2'b01; end
            else if (din == 2'b10) begin next_state = S2; op = 2'b10; end
            else                   begin next_state = S3; op = 2'b11; end
        end

        S1: begin
            if      (din == 2'b00) begin next_state = S1; op = 2'b01; end
            else if (din == 2'b01) begin next_state = S1; op = 2'b01; end
            else if (din == 2'b10) begin next_state = S2; op = 2'b10; end
            else                   begin next_state = S3; op = 2'b11; end
        end

        S2: begin
            if      (din == 2'b11) begin next_state = S3; op = 2'b11; end
            else                   begin next_state = S2; op = 2'b10; end
        end

        S3: begin
            next_state = S3;
            op         = 2'b11;
        end

        default: begin
            next_state = S0;
            op         = 2'b00;
        end

    endcase
end

endmodule