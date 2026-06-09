`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 00:08:48
// Design Name: 
// Module Name: sr_tb
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


module tb_sr_latch;

reg S,R;
wire Q,Qbar;

sr_latch uut(S,R,Q,Qbar);

initial begin
    S=1; R=1; #10; // Hold
    S=0; R=1; #10; // Set
    S=1; R=1; #10; // Hold
    S=1; R=0; #10; // Reset
    S=1; R=1; #10; // Hold
    S=0; R=0; #10; // Invalid
    $finish;
end

endmodule
