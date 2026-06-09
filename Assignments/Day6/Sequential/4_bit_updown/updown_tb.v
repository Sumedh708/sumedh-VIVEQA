`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 00:35:12
// Design Name: 
// Module Name: updown_tb
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

module tb_updown_counter;

reg clk;
reg load;
reg up_down;
reg [3:0] data;

wire [3:0] count;

updown_counter uut(
    clk,
    load,
    up_down,
    data,
    count
);

always #5 clk = ~clk;

initial begin
    clk = 0;

    // Load 5
    load = 1;
    data = 4'd5;
    up_down = 1;
    #10;

    // Count Up
    load = 0;
    up_down = 1;
    #50;

    // Count Down
    up_down = 0;
    #50;

    // Load 12
    load = 1;
    data = 4'd12;
    #10;

    load = 0;
    up_down = 1;
    #30;

    $finish;
end

endmodule
