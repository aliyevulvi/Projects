module status_register(clk, z, n, v, status_z, status_n, status_v);
input clk, z, n, v;
output reg status_z, status_n, status_v;

always @(posedge clk) begin
	status_z <= z;
	status_n <= n;
	status_v <= v;
end

endmodule
