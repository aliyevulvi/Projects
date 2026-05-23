module comp_module(in1, in2, out1);
  input [31:0] in1, in2;
  output [31:0] out1;

  wire [31:0] sub;
  wire onebit;

  assign sub = in1 - in2;
  assign onebit = ~(|sub);
  assign out1 = {31'b0, onebit};
endmodule
