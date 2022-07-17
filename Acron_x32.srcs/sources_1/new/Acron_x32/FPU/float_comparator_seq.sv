module float_comparator_seq
(
	input	logic			clk,
	input	logic			reset,
	input	logic			load,
	
	input	logic			cmp,

	input	logic	[31:0]	a,
	input	logic	[31:0]	b,

	output	logic			greater,
	output	logic			equal,
	output	logic			less,
	output	logic			unordered,

	output	logic			ready
);

	logic	greater_int;
	logic	equal_int;
	logic	less_int;
	logic	unordered_int;

	always_ff @(posedge clk, posedge reset) begin
		if (reset || (load && !cmp)) begin
			greater		<= 1'b0;
			equal		<= 1'b0;
			less		<= 1'b0;
			unordered	<= 1'b0;
			ready		<= 1'b0;
		end

		else if (load) begin
			greater		<= greater_int;
			equal		<= equal_int;
			less		<= less_int;
			unordered	<= unordered_int;
			ready		<= 1'b1;
		end

		else
			ready		<= 1'b0;
	end

	float_comparator_comb float_comparator_inst
	(
		.a(a),
		.b(b),

		.greater(greater_int),
		.equal(equal_int),
		.less(less_int),
		.unordered(unordered_int)
	);

endmodule
