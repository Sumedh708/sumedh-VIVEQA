`timescale 1ns / 1ps

module FA_1bit(input A,B,Cin,
output Sum,Carry
    );
    
assign Sum=A^B^Cin;
assign Carry=(A&B)+(Cin&(A^B));

endmodule
