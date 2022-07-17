module float_sqrt
(
	input	logic					clk,
	input	logic					reset,
	input	logic					load,
	
	input	logic					sqrt,

	input	logic			[23:0]	man_a,
	input	logic	signed	[9:0]	exp_a,
	input	logic					sgn_a,
	input	logic					zero_a,
	input	logic					inf_a,
	input	logic					sNaN_a,
	input	logic					qNaN_a,

	output	logic			[23:0]	man_y,
	output	logic			[9:0]	exp_y,
	output	logic					sgn_y,

	output	logic					round_bit,
	output	logic					sticky_bit,

	output	logic					IV,

	output	logic					final_res,
	output	logic					ready
);

	logic	[25:0]	reg_rad;
	logic	[25:0]	reg_res;
	logic	[27:0]	reg_rem;

	logic	[28:0]	acc [1:0];
	logic	[1:0]	s;

	enum	logic	{IDLE, CALC} state;

	assign			man_y		= reg_res[25:2];
	assign			round_bit	= reg_res[1];
	assign			sticky_bit	= |reg_rem || reg_res[0];

	always @(posedge clk, posedge reset) begin
		if (reset || (load && !sqrt)) begin
			reg_rad		<= 26'h0000000;
			reg_res		<= 26'h0000000;
			reg_rem		<= 28'h0000000;
			exp_y		<= 10'h000;
			sgn_y		<= 1'b0;
			IV			<= 1'b0;
			final_res	<= 1'b0;
			state		<= IDLE;
			ready		<= 1'b0;
		end

		else if (load) begin
			reg_rem		<= 28'h0000000;
			// +0.0 or -0.0
			if (zero_a) begin
				reg_rad		<= 26'h0000000;
				reg_res		<= 26'h0000000;
				exp_y		<= 10'h000;
				sgn_y		<= sgn_a;
				IV			<= 1'b0;
				final_res	<= 1'b1;
				state		<= IDLE;
				ready		<= 1'b1;
			end
			// NaN (negative numbers, except -0.0)
			else if (sgn_a || sNaN_a || qNaN_a) begin
				reg_rad		<= 26'h0000000;
				reg_res		<= {24'hc00000, 2'b00};
				exp_y		<= 10'h0ff;
				sgn_y		<= 1'b0;
				IV			<= 1'b1;
				final_res	<= 1'b1;
				state		<= IDLE;
				ready		<= 1'b1;
			end
			// inf
			else if (inf_a) begin
				reg_rad		<= 26'h0000000;
				reg_res		<= {24'h800000, 2'b00};
				exp_y		<= 10'h0ff;
				sgn_y		<= 1'b0;
				IV			<= 1'b1;
				final_res	<= 1'b1;
				state		<= IDLE;
				ready		<= 1'b1;
			end

			else begin
				reg_rad		<= {1'b0, man_a, 1'b0} << exp_a[0];
				reg_res		<= 26'h0000000;
				exp_y		<= exp_a >>> 1;
				sgn_y		<= 1'b0;
				IV			<= 1'b0;
				final_res	<= 1'b0;
				state		<= CALC;
				ready		<= 1'b0;
			end
		end

		else case (state)
			IDLE:		ready <= 1'b0;

			CALC:		begin
							reg_rad	<= reg_rad << 4;
							reg_res	<= (reg_res << 2) | s;
							reg_rem	<= acc[1][27:0];

							// when the calculation is finished,
							// the MSB of the result is always 1
							if (reg_res[23]) begin
								state	<= IDLE;
								ready	<= 1'b1;
							end
						end
		endcase
	end

	always_comb begin
		acc[0]	= {1'b0, reg_rem[25:0], reg_rad[25:24]} - {1'b0, reg_res, 2'b01};
		s[1]	= !acc[0][28];
		acc[0]	= acc[0][28] ? {1'b0, reg_rem[25:0], reg_rad[25:24]} : acc[0];

		acc[1]	= {1'b0, acc[0][25:0], reg_rad[23:22]} - {1'b0, reg_res[23:0], s[1], 2'b01};
		s[0]	= !acc[1][28];
		acc[1]	= acc[1][28] ? {1'b0, acc[0][25:0], reg_rad[23:22]} : acc[1];
	end

endmodule
