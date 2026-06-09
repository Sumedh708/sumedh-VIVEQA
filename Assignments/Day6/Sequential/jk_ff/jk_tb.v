`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 00:17:32
// Design Name: 
// Module Name: jk_tb
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


module tb_jk_ff;

reg clk,J,K;
wire Q;

jk_ff uut(clk,J,K,Q);

always #5 clk = ~clk;

initial begin
    clk=0;

    J=0; K=0; #10; // Hold
    J=1; K=0; #10; // Set
    J=0; K=0; #10; // Hold
    J=0; K=1; #10; // Reset
    J=1; K=1; #20; // Toggle

    $finish;
end

endmodule
