`timescale 1ns / 1ps

module seq_detecton(input clk,din,
output reg detect);
parameter S0=2'b00,
          S1=2'b01,
          S2=2'b10;
reg [1:0]state,next_state;
initial state = S0;
always @(posedge clk) begin
    state<=next_state;
end
always @(*) begin
    case(state)
    S0: if(din==1'b1) begin
        next_state=S1;
        end else
        next_state=S0;
    S1: if(din==1'b1) begin
        next_state=S2;
        end else
        next_state=S0;    
    S2: if(din==1'b1) begin
        next_state=S1;
        end else 
        next_state=S0;
        
    endcase       
end
always @(*)
begin
    detect = (state == S2 && din == 0);
end
endmodule


