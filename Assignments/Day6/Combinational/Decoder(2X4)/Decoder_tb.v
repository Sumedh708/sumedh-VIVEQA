`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2026 20:21:37
// Design Name: 
// Module Name: Decoder_tb
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

module tb_decoder2x4;

reg [1:0] a;
wire [3:0] y;

Decoder uut(a,y);

initial begin
    a=0;
    repeat(4) begin
        #10 a=a+1;
    end
    #10 $finish;
end

endmodule
