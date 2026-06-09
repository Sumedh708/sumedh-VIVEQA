`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2026 21:23:15
// Design Name: 
// Module Name: ripple_adder_tb
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


module tb_rca4;

reg [3:0] a,b;
reg cin;
wire [3:0] sum;
wire cout;

rca4 uut(a,b,cin,sum,cout);

initial begin
    a=4'd5; b=4'd3; cin=0; #10;
    a=4'd7; b=4'd8; cin=0; #10;
    a=4'd15; b=4'd1; cin=0; #10;
    $finish;
end

endmodule
