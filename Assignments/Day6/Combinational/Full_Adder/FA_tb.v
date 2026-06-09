`timescale 1ns / 1ps

module FA_tb();
reg A,B,Cin;
wire Sum,Carry;

FA_1bit uut(.A(A),.B(B),.Cin(Cin),.Sum(Sum),.Carry(Carry));
initial begin
A=1;B=1;Cin=1;#10;
A=0;B=1;Cin=1;#10;
A=1;B=0;Cin=1;#10;
A=0;B=1;Cin=0;#10;
A=0;B=0;Cin=0;#10;

end

endmodule
