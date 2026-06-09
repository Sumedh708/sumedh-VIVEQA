`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 00:34:20
// Design Name: 
// Module Name: updown_count
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

module updown_counter(
    input clk,
    input load,
    input up_down,
    input [3:0] data,
    output reg [3:0] count
);

always @(posedge clk)
begin
    if(load)
        count <= data;

    else if(up_down)
        count <= count + 1;

    else
        count <= count - 1;
end

endmodule
