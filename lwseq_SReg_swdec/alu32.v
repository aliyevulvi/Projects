module alu32(sum,a,b,zout,nout,vout,gin);
output [31:0] sum;
input [31:0] a,b;
input [2:0] gin;
output zout, nout, vout;
reg [31:0] sum;
reg [31:0] less;
reg zout, nout, vout;

always @(a or b or gin)
begin
	vout = 1'b0;
	case(gin)
	3'b010: begin
		sum = a + b;
		vout = (~a[31] & ~b[31] & sum[31]) | (a[31] & b[31] & ~sum[31]);
	end
	3'b110: begin
		sum = a + 1 + (~b);
		vout = (a[31] & ~b[31] & ~sum[31]) | (~a[31] & b[31] & sum[31]);
	end
	3'b111: begin
		less = a + 1 + (~b);
		if (less[31]) sum = 1;
		else sum = 0;
	end
	3'b000: sum = a & b;
	3'b001: sum = a | b;
	default: sum = 32'bx;
	endcase
	zout = ~(|sum);
	nout = sum[31];
end
endmodule
