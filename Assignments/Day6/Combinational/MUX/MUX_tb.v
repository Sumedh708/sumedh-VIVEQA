`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2026 21:54:02
// Design Name: 
// Module Name: MUX_tb
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

module tb_mux4x1;

reg i0,i1,i2,i3;
reg [1:0] s;
wire y;

mux4x1 uut(i0,i1,i2,i3,s,y);

initial begin
    i0=0; i1=1; i2=0; i3=1;

    s=2'b00; #10;
    s=2'b01; #10;
    s=2'b10; #10;
    s=2'b11; #10;

    $finish;
end

endmodule
