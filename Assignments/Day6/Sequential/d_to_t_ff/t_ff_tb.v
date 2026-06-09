`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 00:22:06
// Design Name: 
// Module Name: t_ff_tb
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

module tb_t_ff;

reg clk,T;
wire Q;

t_ff uut(clk,T,Q);

always #5 clk = ~clk;

initial begin
    clk=0;

    T=0; #20;
    T=1; #40;
    T=0; #20;

    $finish;
end

endmodule
