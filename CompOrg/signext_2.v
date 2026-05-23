module signext_2(in1,out1);
input [4:0] in1;
output [15:0] out1;
assign out1 = {11'b0, in1};
endmodule