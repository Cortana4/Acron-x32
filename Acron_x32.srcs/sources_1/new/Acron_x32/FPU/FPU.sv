`include "FPU_constants.svh"

module FPU
(
	input	logic			clk,
	input	logic			reset,
	input	logic			load,

	input	logic	[3:0]	op,
	input	logic	[2:0]	rm,
	
	input	logic	[31:0]	a,
	input	logic	[31:0]	b,

	output	logic	[31:0]	result,

	output	logic			IV,
	output	logic			DZ,
	output	logic			OF,
	output	logic			UF,
	output	logic			IE,

	output	logic			greater,
	output	logic			equal,
	output	logic			less,
	output	logic			unordered,

	output	logic			ready
);
	// operations
	logic			add;	assign	add		= op == `FPU_OP_ADD;
	logic			sub;	assign	sub		= op == `FPU_OP_SUB;
	logic			mul;	assign	mul		= op == `FPU_OP_MUL;
	logic			div;	assign	div		= op == `FPU_OP_DIV;
	logic			sqrt;	assign	sqrt	= op == `FPU_OP_SQRT;
	logic			neg;	assign	neg		= op == `FPU_OP_NEG;
	logic			abs;	assign	abs		= op == `FPU_OP_ABS;
	logic			cvtfi;	assign	cvtfi	= op == `FPU_OP_CVTFI;
	logic			cvtfu;	assign	cvtfu	= op == `FPU_OP_CVTFU;
	logic			cvtif;	assign	cvtif	= op == `FPU_OP_CVTIF;
	logic			cvtuf;	assign	cvtuf	= op == `FPU_OP_CVTUF;
	logic			cmp;	assign	cmp		= op == `FPU_OP_CMP;

	// input a
	logic	[23:0]	man_a;
	logic	[7:0]	exp_a;
	logic			sgn_a;
	logic			zero_a;
	logic			inf_a;
	logic			sNaN_a;
	logic			qNaN_a;
	logic			denormal_a;
	logic 	[23:0]	man_a_norm;
	logic 	[9:0]	exp_a_norm;

	// input b
	logic 	[23:0]	man_b;
	logic 	[7:0]	exp_b;
	logic			sgn_b;
	logic			zero_b;
	logic			inf_b;
	logic			sNaN_b;
	logic			qNaN_b;
	logic			denormal_b;
	logic 	[23:0]	man_b_norm;
	logic 	[9:0]	exp_b_norm;

	// arithmetic
	logic 	[31:0]	result_arith;
	logic			IV_arith;
	logic			DZ_arith;
	logic			OF_arith;
	logic			UF_arith;
	logic			IE_arith;
	logic			ready_arith;
	logic			sel_arith;

	// sign modifier
	logic	[31:0]	result_sgn_mod;
	logic			ready_sgn_mod;
	logic			sel_sgn_mod;

	// ftoi converter
	logic	[31:0]	result_ftoi;
	logic			IV_ftoi;
	logic			IE_ftoi;
	logic			ready_ftoi;
	logic			sel_ftoi;

	// itof converter
	logic	[31:0]	result_itof;
	logic			IE_itof;
	logic			ready_itof;
	logic			sel_itof;

	// comparator
	logic			greater_int;
	logic			equal_int;
	logic			less_int;
	logic			unordered_int;
	logic			ready_cmp;
	logic			sel_cmp;

	always_ff @(posedge clk, posedge reset) begin
		if (reset) begin
			sel_arith	<= 1'b0;
			sel_sgn_mod	<= 1'b0;
			sel_ftoi	<= 1'b0;
			sel_itof	<= 1'b0;
			sel_cmp		<= 1'b0;
		end

		else if (load) begin
			sel_arith	<= add || sub || mul || div || sqrt;
			sel_sgn_mod	<= neg || abs;
			sel_ftoi	<= cvtfi || cvtfu;
			sel_itof	<= cvtif || cvtuf;
			sel_cmp		<= cmp;
		end
	end
	always_comb begin
		result		= 32'h00000000;
		IV			= 1'b0;
		DZ			= 1'b0;
		OF			= 1'b0;
		UF			= 1'b0;
		IE			= 1'b0;
		greater		= 1'b0;
		equal		= 1'b0;
		less		= 1'b0;
		unordered	= 1'b0;
		ready		= 1'b0;

		if (sel_arith) begin
			result		= result_arith;
			IV			= IV_arith;
			DZ			= DZ_arith;
			OF			= OF_arith;
			UF			= UF_arith;
			IE			= IE_arith;
			ready		= ready_arith;
		end

		else if (sel_sgn_mod) begin
			result		= result_sgn_mod;
			ready		= ready_sgn_mod;
		end

		else if (sel_ftoi) begin
			result		= result_ftoi;
			IV			= IV_ftoi;
			IE			= IE_ftoi;
			ready		= ready_ftoi;
		end

		else if (sel_itof) begin
			result		= result_itof;
			IE			= IE_itof;
			ready		= ready_itof;
		end

		else if (sel_cmp) begin
			greater		= greater_int;
			equal		= equal_int;
			less		= less_int;
			unordered	= unordered_int;
			ready		= ready_cmp;
		end
	end

	splitter splitter_a
	(
		.float_in(a),

		.man(man_a),
		.Exp(exp_a),
		.sgn(sgn_a),

		.zero(zero_a),
		.inf(inf_a),
		.sNaN(sNaN_a),
		.qNaN(qNaN_a),
		.denormal(denormal_a)
	);

	pre_normalizer pre_normalizer_a
	(
		.zero(zero_a),
		.denormal(denormal_a),

		.man_in(man_a),
		.exp_in(exp_a),

		.man_out(man_a_norm),
		.exp_out(exp_a_norm)
	);

	splitter splitter_b
	(
		.float_in(b),

		.man(man_b),
		.Exp(exp_b),
		.sgn(sgn_b),

		.zero(zero_b),
		.inf(inf_b),
		.sNaN(sNaN_b),
		.qNaN(qNaN_b),
		.denormal(denormal_b)
	);

	pre_normalizer pre_normalizer_b
	(
		.zero(zero_b),
		.denormal(denormal_b),

		.man_in(man_b),
		.exp_in(exp_b),

		.man_out(man_b_norm),
		.exp_out(exp_b_norm)
	);

	float_arithmetic float_arithmetic_inst
	(
		.clk(clk),
		.reset(reset),
		.load(load),

		.add(add),
		.sub(sub),
		.mul(mul),
		.div(div),
		.sqrt(sqrt),

		.rm(rm),

		.man_a(man_a_norm),
		.exp_a(exp_a_norm),
		.sgn_a(sgn_a),
		.zero_a(zero_a),
		.inf_a(inf_a),
		.sNaN_a(sNaN_a),
		.qNaN_a(qNaN_a),

		.man_b(man_b_norm),
		.exp_b(exp_b_norm),
		.sgn_b(sgn_b),
		.zero_b(zero_b),
		.inf_b(inf_b),
		.sNaN_b(sNaN_b),
		.qNaN_b(qNaN_b),

		.float_out(result_arith),

		.IV(IV_arith),
		.DZ(DZ_arith),
		.OF(OF_arith),
		.UF(UF_arith),
		.IE(IE_arith),

		.ready(ready_arith)
	);

	sign_modifier sign_modifier_inst
	(
		.clk(clk),
		.reset(reset),
		.load(load),

		.neg(neg),
		.abs(abs),

		.float_in(a),
		.float_out(result_sgn_mod),

		.ready(ready_sgn_mod)
	);

	ftoi_converter ftoi_converter_inst
	(
		.clk(clk),
		.reset(reset),
		.load(load),

		.rm(rm),
		.cvtfi(cvtfi),
		.cvtfu(cvtfu),

		.man_a(man_a),
		.exp_a(exp_a),
		.sgn_a(sgn_a),
		.zero_a(zero_a),
		.inf_a(inf_a),
		.sNaN_a(sNaN_a),
		.qNaN_a(qNaN_a),

		.int_out(result_ftoi),

		.IV(IV_ftoi),
		.IE(IE_ftoi),

		.ready(ready_ftoi)
	);

	itof_converter itof_converter_inst
	(
		.clk(clk),
		.reset(reset),
		.load(load),

		.rm(rm),
		.cvtif(cvtif),
		.cvtuf(cvtuf),

		.int_in(a),
		.float_out(result_itof),
		.IE(IE_itof),

		.ready(ready_itof)
	);

	float_comparator_seq float_comparator_inst
	(
		.clk(clk),
		.reset(reset),
		.load(load),

		.cmp(cmp),

		.a(a),
		.b(b),

		.greater(greater_int),
		.equal(equal_int),
		.less(less_int),
		.unordered(unordered_int),

		.ready(ready_cmp)
	);

endmodule