`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2026 21:47:05
// Design Name: 
// Module Name: MUX4
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

module mux4x1(
    input i0,i1,i2,i3,
    input [1:0] s,
    output y
);

wire w1,w2;

mux2x1 m1(i0,i1,s[0],w1);
mux2x1 m2(i2,i3,s[0],w2);
mux2x1 m3(w1,w2,s[1],y);

endmodule
