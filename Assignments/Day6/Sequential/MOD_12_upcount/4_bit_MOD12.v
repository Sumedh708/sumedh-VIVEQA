`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 00:30:14
// Design Name: 
// Module Name: 4_bit_MOD12
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

module mod12_counter(
    input clk,
    input load,
    input [3:0] data,
    output reg [3:0] count
);

always @(posedge clk)
begin
    if(load)
        count <= data;

    else if(count == 4'd11)
        count <= 4'd0;

    else
        count <= count + 1;
end

endmodule
