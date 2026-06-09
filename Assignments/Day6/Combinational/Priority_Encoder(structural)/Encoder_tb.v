`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2026 20:33:13
// Design Name: 
// Module Name: Encoder_tb
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

module tb_priority_encoder8x3;

reg [7:0] d;
wire [2:0] y;

Encoder uut(d,y);

initial begin
    d=8'b00000001; #10;
    d=8'b00000010; #10;
    d=8'b00000100; #10;
    d=8'b00001000; #10;
    d=8'b00010000; #10;
    d=8'b00100000; #10;
    d=8'b01000000; #10;
    d=8'b10000000; #10;
    $finish;
end

endmodule
