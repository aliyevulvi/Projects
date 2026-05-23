module mult3_to_1_32(out, i0, i1, i2, sel1, sel2);
  output [31:0] out;
  input [31:0] i0, i1, i2;
  input sel1, sel2;

  assign out = (sel1 == 1'b0 & sel2 == 1'b0) ? i0 :
               (sel1 == 1'b0 & sel2 == 1'b1) ? i1 :
               (sel1 == 1'b1 & sel2 == 1'b0) ? i2 :
               i0;
endmodule
