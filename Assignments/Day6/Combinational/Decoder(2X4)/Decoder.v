`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2026 20:17:48
// Design Name: 
// Module Name: Decoder
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


module Decoder(
input [1:0] a,
output [3:0] y
);
assign y[0]=~a[1]&~a[0];
assign y[1]=~a[1]& a[0];
assign y[2]= a[1]&~a[0];
assign y[3]= a[1]& a[0];

endmodule
