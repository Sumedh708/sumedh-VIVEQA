`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2026 20:30:54
// Design Name: 
// Module Name: Encoder
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


module Encoder(
    input [7:0] d,
    output [2:0] y
);
assign y[2] = d[7]|d[6]|d[5]|d[4];
assign y[1] = d[7]|d[6]|(~d[7]&~d[6]&~d[5]&~d[4]&d[3])|(~d[7]&~d[6]&~d[5]&~d[4]&d[2]);
assign y[0] = d[7]|(~d[7]&d[6])|(~d[7]&~d[6]&~d[5]&d[4])|(~d[7]&~d[6]&~d[5]&~d[4]&~d[3]&d[2])|(~d[7]&~d[6]&~d[5]&~d[4]&~d[3]&~d[2]&d[1]);
endmodule