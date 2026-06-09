`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 00:16:34
// Design Name: 
// Module Name: jk_ff
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module jk_ff #(
    parameter HOLD   = 2'b00,
    parameter RESET  = 2'b01,
    parameter SET    = 2'b10,
    parameter TOGGLE = 2'b11
)(
    input clk,
    input J,
    input K,
    output reg Q
);

always @(posedge clk)
begin
    case({J,K})
        HOLD   : Q <= Q;
        RESET  : Q <= 1'b0;
        SET    : Q <= 1'b1;
        TOGGLE : Q <= ~Q;
    endcase
end

endmodule
