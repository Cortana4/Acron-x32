`include "Acron_x32_constants.svh"

module register_file
(
	input	logic			clk,
	input	logic			reset,

	input	logic			write_a,
	input	logic	[5:0]	dst_a_addr,
	input	logic	[31:0]	dst_a_data,

	input	logic			write_b,
	input	logic	[5:0]	dst_b_addr,
	input	logic	[31:0]	dst_b_data,

	input	logic	[5:0]	src_a_addr,
	output	logic	[31:0]	src_a_data,

	input	logic	[5:0]	src_b_addr,
	output	logic	[31:0]	src_b_data
);
	// registers[0] is nullptr
	logic	[31:0]	registers [61:1];

	logic			read_src_a;
	logic			read_src_b;
	logic			write_dst_a;
	logic			write_dst_a;

	assign			read_src_a	= src_a_addr != 6'd0 && src_a_addr != `SR && src_a_addr != `PC;
	assign			read_src_b	= src_b_addr != 6'd0 && src_b_addr != `SR && src_b_addr != `PC;
	assign			write_dst_a	= dst_a_addr != 6'd0 && dst_a_addr != `SR && dst_a_addr != `PC && write_a;
	assign			write_dst_b	= dst_b_addr != 6'd0 && dst_a_addr != `SR && dst_a_addr != `PC && write_a;

	assign			src_a_data	= read_src_a ? registers[src_a_addr] : 32'h00000000;
	assign			src_b_data	= read_src_b ? registers[src_b_addr] : 32'h00000000;

	always_ff @(posedge clk, posedge reset) begin
		if (reset) begin
			for (integer i = 1; i <= 61; i = i + 1)
				registers[i] <= 32'h00000000;
		end

		else begin
			if (write_dst_a)
				registers[dst_a_addr] <= dst_a_data;

			if (write_dst_b)
				registers[dst_b_addr] <= dst_b_data;
		end
	end

endmodule