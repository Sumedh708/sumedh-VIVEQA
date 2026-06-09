`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 00:21:09
// Design Name: 
// Module Name: t_ff
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

module t_ff(
    input clk,
    input T,
    output Q
);

wire q_int;
wire d;

assign d = T ^ q_int;

d_ff d1(
    .clk(clk),
    .D(d),
    .Q(q_int)
);

assign Q = q_int;

endmodule
