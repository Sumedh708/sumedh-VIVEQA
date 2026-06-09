`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2026 23:11:38
// Design Name: 
// Module Name: decoder2_tb
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


module tb_decoder3x8;

reg [2:0] a;
wire [7:0] y;

decoder3x8 uut(a,y);

initial begin
    a=0;
    repeat(8) begin
        #10 a=a+1;
    end
    #10 $finish;
end

endmodule
