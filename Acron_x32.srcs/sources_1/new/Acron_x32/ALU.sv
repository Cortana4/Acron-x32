`include "Acron_x32_constants.svh"

module ALU
(
	input	logic	[3:0]	op,
	input	logic			C_in,

	input	logic	[31:0]	a,
	input	logic	[31:0]	b,

	output	logic	[31:0]	y,
	output	logic			C,
	output	logic			Z,
	output	logic			N,
	output	logic			V,
	output	logic			S
);

	assign	Z = ~|y;
	assign	N = y[31];
	assign	S = N ^ V;

	always_comb begin
		case (op)
		`ALU_ADD:	begin
						{C, y}	= a + b;
						V		= a[31] && b[31] && !y[31] || !a[31] && !b[31] && y[31];
					end

		`ALU_ADC:	begin
						{C, y}	= a + b + C_in;
						V		= a[31] && b[31] && !y[31] || !a[31] && !b[31] && y[31];
					end

		`ALU_SUB:	begin
						{C, y}	= a - b;
						V		= a[31] && !b[31] && !y[31] || !a[31] && b[31] && y[31];
					end

		`ALU_SBC:	begin
						{C, y}	= a - b - C_in;
						V		= a[31] && !b[31] && !y[31] || !a[31] && b[31] && y[31];
					end

		`ALU_INC:	begin
						y		= a + 32'd1;
						C		= C_in;
						V		= y[31] && ~|y[30:0];
					end

		`ALU_DEC:	begin
						y		= a - 32'd1;
						C		= C_in;
						V		= !y[31] && &y[30:0];
					end

		`ALU_NEG:	begin
						{C, y}	= -a;
						V		= y[31] && ~|y[30:0];
					end

		`ALU_AND:	begin
						y		= a & b;
						C		= C_in;
						V		= 1'b0;
					end

		`ALU_OR:		begin
						y		= a | b;
						C		= C_in;
						V		= 1'b0;
					end

		`ALU_XOR:	begin
						y		= a ^ b;
						C		= C_in;
						V		= 1'b0;
					end

		`ALU_NOT:	begin
						y		= ~a;
						C		= 1'b1;
						V		= 1'b0;
					end

		`ALU_LSL:	begin
						{C, y}	= {C_in, a} << (~|b[31:6] ? b[5:0] : 6'd33);
						V		= N ^ C;
					end

		`ALU_LSR:	begin
						{y, C}	= {a, C_in} >> (~|b[31:6] ? b[5:0] : 6'd33);
						V		= N ^ C;
					end

		`ALU_ASR:	begin
						{y, C}	= {a, C_in} >>> (~|b[31:6] ? b[5:0] : 6'd33);
						V		= N ^ C;
					end
/*
		`ALU_ROL:	begin
						y		= (a << b[4:0]) | (a >> (6'd32 - b[4:0]));
						C		= |b ? y[0] : C_in;
						V		= N ^ C;
					end
*/
		`ALU_ROR:	begin
						y		= (a >> b[4:0]) | (a << (6'd32 - b[4:0]));
						C		= |b ? y[31] : C_in;
						V		= N ^ C;
					end
/*
		`ALU_RLX:	begin
						{C, y}	= {y[30:0], C_in};
						V		= N ^ C;
					end
*/
		`ALU_RRX:	begin
						{y, C}	= {C_in, y[31:1]};
						V		= N ^ C;
					end

		default:	begin
						y		= 32'h000000000;
						C		= 1'b0;
						V		= 1'b0;
					end
		endcase
	end

endmodule