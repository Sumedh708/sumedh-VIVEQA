`timescale 1ns / 1ps
`timescale 1ns / 1ps

module tb_seq_detection;

reg clk;
reg din;
wire detect;

seq_detecton uut(
    .clk(clk),
    .din(din),
    .detect(detect)
);

always #5 clk = ~clk;

initial
begin
    clk = 0;
end

initial
begin
    // Sequence: 110110

    din = 1; #10;
    din = 1; #10;
    din = 0; #10; // Detect = 1

    din = 1; #10;
    din = 1; #10;
    din = 0; #10; // Detect = 1

    #20;
    $finish;
end

initial
begin
    $monitor("Time=%0t din=%b state=%b detect=%b",
              $time, din, uut.state, detect);
end

endmodule

