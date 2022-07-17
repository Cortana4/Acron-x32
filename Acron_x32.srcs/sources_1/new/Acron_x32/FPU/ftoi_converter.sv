`include "FPU_constants.svh"

module ftoi_converter
(
	input	logic			clk,
	input	logic			reset,
	input	logic			load,
	
	input	logic	[2:0]	rm,
	input	logic			cvtfi,
	input	logic			cvtfu,

	input	logic	[23:0]	man_a,
	input	logic	[7:0]	exp_a,
	input	logic			sgn_a,
	input	logic			zero_a,
	input	logic			inf_a,
	input	logic			sNaN_a,
	input	logic			qNaN_a,

	output	logic	[31:0]	int_out,

	output	logic			IV,
	output	logic			IE,
	
	output	logic			ready
);

	logic	[31:0]	cmp_min;
	logic			less;
	
	logic	[31:0]	cmp_max;
	logic			greater;

	logic	[7:0]	offset;
	logic	[32:0]	shifter_out;
	logic			sticky_bit;
	
	logic	[2:0]	reg_rm;
	logic	[31:0]	reg_int;
	logic			reg_sgn;
	logic			reg_round_bit;
	logic			reg_sticky_bit;
	logic			reg_IV;
	logic			reg_IE;
	logic			negate;
	logic			final_res;

	logic	[31:0]	int_rounded;
	logic			inexact;
	
	assign			offset = 8'h9e - exp_a;
	
	/* calculate offset:
	 *	 31 - exp_unbiased
	 * = 31 + bias - (exp_unbiased + bias)
	 * = 31 + bias - exp_biased
	 * = 31 + 127 - exp_biased
	 */

	always_comb begin
		if (final_res) begin
			int_out	= reg_int;
			IV		= reg_IV;
			IE		= reg_IE;
		end
		
		else begin
			int_out	= negate ? -int_rounded : int_rounded;
			IV		= reg_IV;
			IE		= inexact;
		end
	end
	
	always_ff @(posedge clk, posedge reset) begin
		if (reset || (load && !(cvtfi || cvtfu))) begin
			reg_rm				<= 3'b000;
			reg_int				<= 32'h00000000;
			reg_sgn				<= 1'b0;
			reg_round_bit		<= 1'b0;
			reg_sticky_bit		<= 1'b0;
			reg_IV				<= 1'b0;
			reg_IE				<= 1'b0;
			negate				<= 1'b0;
			final_res			<= 1'b0;
			ready				<= 1'b0;
		end
		
		else if (load) begin
			reg_rm	<= rm;
			reg_sgn	<= sgn_a;
			ready	<= 1'b1;
			// input is below lower limit
			if (less || (inf_a && sgn_a)) begin
				reg_int			<= cvtfi ? 32'h80000000 : 32'h00000000;
				reg_round_bit	<= 1'b0;
				reg_sticky_bit	<= 1'b0;
				reg_IV			<= 1'b1;
				reg_IE			<= 1'b1;
				negate			<= 1'b0;
				final_res		<= 1'b1;
			end
			// input is above upper limit or NaN
			else if (greater || (inf_a && !sgn_a) || sNaN_a || qNaN_a) begin
				reg_int			<= cvtfi ? 32'h7fffffff : 32'hffffffff;
				reg_round_bit	<= 1'b0;
				reg_sticky_bit	<= 1'b0;
				reg_IV			<= 1'b1;
				reg_IE			<= 1'b1;
				negate			<= 1'b0;
				final_res		<= 1'b1;
			end
			// rounded input is zero
			else if ((!cvtfi && sgn_a) || zero_a) begin
				reg_int			<= 32'h0000000;
				reg_round_bit	<= 1'b0;
				reg_sticky_bit	<= 1'b0;
				reg_IV			<= 1'b0;
				reg_IE			<= 1'b0;
				negate			<= 1'b0;
				final_res		<= 1'b1;
			end
			
			else begin
				reg_int			<= shifter_out[32:1];
				reg_round_bit	<= shifter_out[0];
				reg_sticky_bit	<= sticky_bit;
				reg_IV			<= 1'b0;
				reg_IE			<= 1'b0;
				negate			<= cvtfi && sgn_a;
				final_res		<= 1'b0;
			end
		end
		
		else
			ready			<= 1'b0;
	end

	always_comb begin
		// set min and max valid int value to compare
		if (cvtfi) begin
			cmp_min = 32'hcf000000;
			cmp_max = 32'h4effffff;
		end
		// set min and max valid unsigned int value to compare
		else begin
			// inputs less than 0.0 are normally invalid
			// inputs less than 0.0 but greater than -1.0
			// can be valid if rounded to 0.0
			case (rm)
			`FPU_RM_RNE:	cmp_min = 32'hbf700000; // < -0.5
			`FPU_RM_RTZ,
			`FPU_RM_RUP:	cmp_min = 32'hbf7fffff; // < -0.99...
			`FPU_RM_RMM:	cmp_min = 32'hbeffffff; // < -0.49...
			default:		cmp_min = 32'h00000000; // <  0.0
			endcase

			cmp_max = 32'h4f7fffff;
		end
	end

	float_comparator_comb float_comparator_inst_1
	(
		.a({sgn_a, exp_a, man_a[22:0]}),
		.b(cmp_min),

		.greater(),
		.equal(),
		.less(less),
		.unordered()
	);
	
	float_comparator_comb float_comparator_inst_2
	(
		.a({sgn_a, exp_a, man_a[22:0]}),
		.b(cmp_max),

		.greater(greater),
		.equal(),
		.less(),
		.unordered()
	);

	rshifter #(33, 6) rshifter_inst
	(
		.in({man_a, 9'h00}),
		.sel(offset[5:0]),
		.sgn(1'b0),

		.out(shifter_out),
		.sticky_bit(sticky_bit)
	);

	rounding_logic #(32) rounding_logic_inst
	(
		.rm(reg_rm),
	
		.sticky_bit(reg_sticky_bit),
		.round_bit(reg_round_bit),

		.in(reg_int),
		.sgn(reg_sgn),

		.out(int_rounded),
		.carry(),

		.inexact(inexact)
	);

endmodule