`include "Acron_x32_constants.svh"

module register_file
(
	input	logic			clk,
	input	logic			reset,

	input	logic			write,
	input	logic	[5:0]	dst_addr,
	input	logic	[31:0]	dst_data,

	input	logic	[5:0]	src_a_addr,
	output	logic	[31:0]	src_a_data,

	input	logic	[5:0]	src_b_addr,
	output	logic	[31:0]	src_b_data
);
	// registers[0] is nullptr
	logic	[31:0]	registers [61:1];

	logic			read_a;
	logic			read_b;
	logic			write_dst;

	assign			read_a		= src_a_addr != 6'd0 && src_a_addr != `SR && src_a_addr != `PC;
	assign			read_b		= src_b_addr != 6'd0 && src_b_addr != `SR && src_b_addr != `PC;
	assign			write_dst	= dst_addr   != 6'd0 && dst_addr   != `SR && dst_addr   != `PC;
	
	assign			src_a_data	= read_a ? registers[src_a_addr] : 32'h00000000;
	assign			src_b_data	= read_b ? registers[src_b_addr] : 32'h00000000;

	always_ff @(posedge clk, posedge reset) begin
		if (reset) begin
			for (integer i = 1; i <= 61; i = i + 1)
				registers[i] <= 32'h00000000;
		end

		else if (write && write_dst)
			registers[dst_addr] <= dst_data;
	end

endmodule