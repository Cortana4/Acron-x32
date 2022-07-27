`include "Acron_x32_constants.svh"
`include "FPU/FPU_constants.svh"

module inst_decoder
(
	// control unit signals
	input	logic	[3:0]	step_counter,
	input	logic	[31:0]	instruction,

	input	logic			fetch_imm,
	input	logic			ready,
	output	logic			next_step,
	output	logic			stall,
	
	output	logic			ret_int,
	output	logic			wait_int,

	// CPU control signals
	output	logic	[5:0]	src_a_addr,
	output	logic	[5:0]	src_b_addr,
	output	logic	[5:0]	dst_a_addr,
	output	logic	[5:0]	dst_b_addr,
	output	logic	[3:0]	ALU_OP,
	output	logic			MUL_OP,
	output	logic	[1:0]	DIV_OP,
	output	logic	[3:0]	FPU_OP,
	output	logic	[2:0]	FPU_RM,
	output	logic	[3:0]	JMP_OP,

	output	logic	[2:0]	bus_src_sel,
	output	logic			write_dst_a,
	output	logic			write_dst_b,

	output	logic			write_ALU_f,
	output	logic			write_FPU_f,

	output	logic			jump_ena,
	output	logic			src_b_ena,
	output	logic			sel_imm,
	output	logic			float_cmp,

	output	logic			load_MUL,
	output	logic			load_DIV,
	output	logic			load_FPU,
	output	logic			load_MEM,
	output	logic			store_MEM,

	output	logic			set_GIE,
	output	logic			clr_GIE
);

	logic	[5:0]	opcode;
	logic	[7:0]	func;

	// instructions
	always_comb begin
		dst_a_addr	= instruction[5:0];		// 6-bit
		dst_b_addr	= 6'd0;					// 6-bit
		src_b_addr	= instruction[11:6];	// 6-bit
		src_a_addr	= instruction[17:12];	// 6-bit
		func		= instruction[25:18];	// 8-bit
		opcode		= instruction[31:27];	// 5-bit

		ALU_OP		= 4'h0;
		MUL_OP		= 1'b0;
		DIV_OP		= 2'h0;
		FPU_OP		= 4'h0;
		FPU_RM		= 3'h0;
		JMP_OP		= 4'h0;

		next_step	= 1'b0;
		stall		= 1'b0;
		
		ret_int		= 1'b0;
		wait_int	= 1'b0;

		bus_src_sel	= 3'h0;
		write_dst_a	= 1'b0;
		write_dst_b	= 1'b0;

		write_ALU_f	= 1'b0;
		write_FPU_f	= 1'b0;

		jump_ena	= 1'b0;
		src_b_ena	= 1'b1;
		sel_imm		= 1'b0;
		float_cmp	= 1'b0;

		load_MUL	= 1'b0;
		load_DIV	= 1'b0;
		load_FPU	= 1'b0;
		load_MEM	= 1'b0;
		store_MEM	= 1'b0;

		set_GIE		= 1'b0;
		clr_GIE		= 1'b0;

		case (opcode)
		`INR:	if (!fetch_imm) begin
					bus_src_sel	= `SEL_ALU;
					write_dst_a	= 1'b1;
					src_a_addr	= 6'h00;
					sel_imm		= instruction[26];
					ALU_OP		= `ALU_ADD;
				end

		`MOV:	begin
					bus_src_sel	= `SEL_REG;
					write_dst_a	= 1'b1;
				end

		`STM:	if (!fetch_imm) begin
					bus_src_sel	= `SEL_REG;
					sel_imm		= 1'b1;
					ALU_OP		= `ALU_ADD;
					store_MEM	= 1'b1;
				end

		`LDM:	if (!fetch_imm) begin
					case (step_counter)
					4'd0:	begin
								sel_imm		= instruction[26];
								ALU_OP		= `ALU_ADD;
								load_MEM	= 1'b1;
								next_step	= 1'b1;
							end
					4'd1:	begin
								bus_src_sel	= `SEL_MEM;
								write_dst_a	= 1'b1;
							end
					endcase
				end

		`PUSH:	case (step_counter)
				4'd0:	begin // store_MEM register
							bus_src_sel	= `SEL_REG;
							src_a_addr	= `SP;
							src_b_ena	= 1'b0;
							ALU_OP		= `ALU_ADD;
							store_MEM	= 1'b1;
							next_step	= 1'b1;
						end
				4'd1:	begin // increment stack pointer
							bus_src_sel	= `SEL_ALU;
							write_dst_a	= 1'b1;
							src_a_addr	= `SP;
							dst_a_addr	= `SP;
							ALU_OP		= `ALU_INC;
						end
				endcase

		`POP:	case (step_counter)
				4'd0:	begin // decrement stack pointer, set load_MEM address
							bus_src_sel	= `SEL_ALU;
							write_dst_a	= 1'b1;
							src_a_addr	= `SP;
							dst_a_addr	= `SP;
							ALU_OP		= `ALU_DEC;
							load_MEM	= 1'b1;
							next_step	= 1'b1;
						end
				4'd1:	begin // load_MEM register
							bus_src_sel	= `SEL_MEM;
							write_dst_a	= 1'b1;
						end
				endcase

		`ALU:	if (!fetch_imm) begin
					bus_src_sel	= `SEL_ALU;
					write_dst_a	= 1'b1;
					write_ALU_f	= 1'b1;
					sel_imm		= instruction[26];
					ALU_OP		= func[3:0];
				end

		`MUL:	if (!fetch_imm) begin
					case (step_counter)
					4'd0:	begin
								sel_imm		= instruction[26];
								MUL_OP		= func[0];
								load_MUL	= 1'b1;
								next_step	= 1'b1;
							end
					4'd1:	begin
								bus_src_sel	= `SEL_MULL;
								dst_b_addr	= func[7:2];
								write_dst_a	= ready;
								write_dst_b	= ready;
								stall		= !ready;
							end
					endcase
				end

		`DIV:	if (!fetch_imm) begin
					case (step_counter)
					4'd0:	begin
								sel_imm		= instruction[26];
								DIV_OP		= func[1:0];
								load_DIV	= 1'b1;
								next_step	= 1'b1;
							end
					4'd1:	begin
								bus_src_sel	= `SEL_DIV;
								write_dst_a	= ready;
								stall		= !ready;
							end
					endcase
				end

		`FPU:	if (!fetch_imm) begin
					case (step_counter)
					4'd0:	begin
								sel_imm		= instruction[26];
								FPU_OP		= func[3:0];
								FPU_RM		= func[6:4];
								load_FPU	= 1'b1;
								next_step	= 1'b1;
							end
					4'd1:	begin
								bus_src_sel	= `SEL_FPU;
								write_dst_a	= ready;
								write_FPU_f	= ready;
								float_cmp	= FPU_OP == `FPU_OP_CMP;
								write_ALU_f	= ready && float_cmp;
								stall		= !ready;
							end
					endcase
				end

		`JMP:	if (!fetch_imm) begin
					jump_ena	= 1'b1;
					sel_imm		= instruction[26];
					JMP_OP		= func[3:0];
					ALU_OP		= `ALU_ADD;
				end

		`IEN:	set_GIE		= 1'b1;

		`IDI:	clr_GIE		= 1'b0;

		`WAIT:	wait_int	= 1'b1;

		`RETI:	ret_int		= 1'b1;

		`CALL:	if (!fetch_imm) begin
					case (step_counter)
					4'd0:	begin // push program counter
								bus_src_sel	= `SEL_REG;
								src_a_addr	= `SP;
								src_b_addr	= `PC;
								src_b_ena	= 1'b0;
								ALU_OP		= `ALU_ADD;
								store_MEM	= 1'b1;
								next_step	= 1'b1;
							end
					4'd1:	begin // increment stack pointer
								bus_src_sel	= `SEL_ALU;
								write_dst_a	= 1'b1;
								src_a_addr	= `SP;
								dst_a_addr	= `SP;
								ALU_OP		= `ALU_INC;
								next_step	= 1'b1;
							end
					4'd2:	begin // jump
								write_dst_a	= 1'b1;
								dst_a_addr	= `PC;
								sel_imm		= instruction[26];
								ALU_OP		= `ALU_ADD;
							end
					endcase
				end

		`RET:	case (step_counter)
				4'd0:	begin // decrement stack pointer, set load_MEM address
							bus_src_sel	= `SEL_ALU;
							write_dst_a	= 1'b1;
							src_a_addr	= `SP;
							dst_a_addr	= `SP;
							ALU_OP		= `ALU_DEC;
							load_MEM	= 1'b1;
							next_step	= 1'b1;
						end
				4'd1:	begin
							bus_src_sel	= `SEL_MEM;
							write_dst_a	= 1'b1;
							dst_a_addr	= `PC;
						end
				endcase
		endcase
	end

endmodule