`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 00:26:51
// Design Name: 
// Module Name: up_count_tb
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

module tb_up_counter;

reg clk,load;
reg [3:0] data;
wire [3:0] count;

up_counter uut(clk,load,data,count);

always #5 clk=~clk;

initial begin
    clk=0;

    load=1;
    data=4'd5;
    #10;

    load=0;
    #80;

    load=1;
    data=4'd10;
    #10;

    load=0;
    #40;

    $finish;
end

endmodule
