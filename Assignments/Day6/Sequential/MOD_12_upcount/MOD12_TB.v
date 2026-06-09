`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 00:31:14
// Design Name: 
// Module Name: MOD12_TB
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

module tb_mod12_counter;

reg clk,load;
reg [3:0] data;
wire [3:0] count;

mod12_counter uut(clk,load,data,count);

always #5 clk=~clk;

initial begin
    clk=0;

    load=1;
    data=4'd9;
    #10;

    load=0;
    #100;

    $finish;
end

endmodule
