`include "Acron_x32_constants.svh"

module jump_logic
(
	input	logic			C,
	input	logic			Z,
	input	logic			N,
	input	logic			V,
	input	logic			S,

	input	logic			ena,
	input	logic	[3:0]	con,
	output	logic			jump
);

	logic	jump_int;
	assign	jump = jump_int && ena;

	always_comb begin
		case (con)
		`JMP_EQ:	jump_int = Z;
		`JMP_NE:	jump_int = !Z;
		`JMP_HI:	jump_int = !(C || Z);
		`JMP_SH:	jump_int = !C;
		`JMP_SL:	jump_int = C || Z;
		`JMP_LO:	jump_int = C;
		`JMP_GT:	jump_int = !(S || Z);
		`JMP_GE:	jump_int = !S;
		`JMP_LE:	jump_int = S || Z;
		`JMP_LT:	jump_int = S;
		`JMP_MI:	jump_int = N;
		`JMP_PL:	jump_int = !N;
		`JMP_VS:	jump_int = V;
		`JMP_VC:	jump_int = !V;
		`JMP_AL:	jump_int = 1'b1;
		default:	jump_int = 1'b0;
		endcase
	end

endmodule