`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.06.2026 12:00:36
// Design Name: 
// Module Name: fsm_tb
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

`timescale 1ns/1ps

module tb_fsm_2;

reg clk;
reg rst;
reg [1:0] din;
wire [1:0] op;

fsm_2 uut(
    .clk(clk),
    .din(din),
    .rst(rst),
    .op(op)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin

    // Reset
    rst = 1;
    din = 2'b00;
    #12;
    rst = 0;

    // Sequence : 0 0 1 0 3 2
    @(posedge clk) din = 2'b00;   // 0
    @(posedge clk) din = 2'b00;   // 0
    @(posedge clk) din = 2'b01;   // 1
    @(posedge clk) din = 2'b00;   // 0
    @(posedge clk) din = 2'b11;   // 3
    @(posedge clk) din = 2'b10;   // 2
    rst=1;
    #10
    // Additional test sequences
    rst=0;
    // 0 1 2 3
    @(posedge clk) din = 2'b00;
    @(posedge clk) din = 2'b01;
    @(posedge clk) din = 2'b10;
    @(posedge clk) din = 2'b11;

    // 3 3 3
    @(posedge clk) din = 2'b11;
    @(posedge clk) din = 2'b11;
    @(posedge clk) din = 2'b11;

    // 2 1 0
    @(posedge clk) din = 2'b10;
    @(posedge clk) din = 2'b01;
    @(posedge clk) din = 2'b00;

    #20;
    $finish;
end

initial begin
    $monitor("Time=%0t rst=%b din=%0d state_op=%0d",
             $time, rst, din, op);
end

endmodule