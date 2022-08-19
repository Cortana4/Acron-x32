`include "Acron_x32_constants.svh"

module int_divider
#(
	parameter		n = 32,
	parameter		m = 8
)
(
	input	logic			clk,
	input	logic			reset,
	input	logic			load,

	input	logic	[1:0]	op,

	input	logic	[n-1:0]	a,
	input	logic	[n-1:0]	b,

	output	logic	[n-1:0]	y,
	output	logic			C,
	output	logic			Z,
	output	logic			N,
	output	logic			S,

	output	logic			ready
);

	logic	[1:0]	reg_op;
	logic	[n-1:0]	reg_b;
	logic	[n-1:0]	reg_res;
	logic	[n:0]	reg_rem;
	logic			reg_sgn;

	logic	[n:0]	acc [m:0];
	logic	[m-1:0]	q;

	integer			counter;

	enum	logic	{IDLE, CALC} state;

	assign			C = ~|reg_b;
	assign			Z = ~|y;
	assign			N = y[n-1];
	assign			S = reg_sgn;

	always_comb begin
		case (reg_op)
		`UDIV: y = reg_res;
		`SDIV: y = reg_sgn ? -reg_res : reg_res;
		`UMOD: y = reg_rem;
		`SMOD: y = reg_sgn ? -reg_rem : reg_rem;
		endcase
	end

	always_ff @(posedge clk, posedge reset) begin
		if (reset) begin
			reg_op	<= 2'b00;
			reg_b	<= 0;
			reg_res	<= 0;
			reg_rem	<= 0;
			reg_sgn	<= 1'b0;
			counter	<= 0;
			state	<= IDLE;
			ready	<= 1'b0;
		end

		else if (load) begin
			reg_op	<= op;
			reg_rem	<= 0;
			counter	<= 0;
			state	<= CALC;
			ready	<= 1'b0;

			case (op)
			`UDIV,
			`UMOD:	begin
						reg_b	<= b;
						reg_res	<= a;
						reg_sgn	<= 1'b0;
					end
			`SDIV:	begin
						reg_b	<= b[n-1] ? -b : b;
						reg_res	<= a[n-1] ? -a : a;
						reg_sgn	<= a[n-1] ^ b[n-1];
					end
			`SMOD:	begin
						reg_b	<= b[n-1] ? -b : b;
						reg_res	<= a[n-1] ? -a : a;
						reg_sgn	<= a[n-1];
					end
			endcase
		end

		else case (state)
			IDLE:	ready	<= 1'b0;
			CALC:	begin
						reg_res	<= (reg_res << m) | q;
						reg_rem	<= acc[m];

						if (counter == n/m-1) begin
							state	<= IDLE;
							ready	<= 1'b1;
						end

						else
							counter	<= counter + 1;
					end
		endcase
	end

	always_comb begin
		acc[0]	= reg_rem;

		for (integer i = 1; i <= m; i = i+1) begin
			acc[i]	= {acc[i-1][n-1:0], reg_res[n-i]} - {1'b0, reg_b};
			q[m-i]	= !acc[i][n];
			acc[i]	= acc[i][n] ? {acc[i-1][n-1:0], reg_res[n-i]} : acc[i];
		end
	end

endmodule
