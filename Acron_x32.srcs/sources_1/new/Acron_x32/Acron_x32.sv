`include "Acron_x32_constants.svh"

module Acron_x32
(
	input	logic			clk,
	input	logic			reset,

	output	logic	[31:0]	dmem_addr,
	input	logic	[31:0]	dmem_din,
	output	logic	[31:0]	dmem_dout,
	output	logic			write,

	output	logic	[31:0]	imem_addr,
	input	logic	[31:0]	imem_din,

	input	logic			int0,
	input	logic			int1,
	input	logic			int2,
	input	logic			int3,
	input	logic			int4,
	input	logic			int5,
	input	logic			int6,
	input	logic			int7,

	output	logic			CPU_halt
);

	// bus control
	logic			src_b_ena;
	logic			write_dst_a;
	logic			write_dst_b;

	logic	[5:0]	src_a_addr;
	logic	[5:0]	src_b_addr;
	logic	[5:0]	dst_a_addr;
	logic	[5:0]	dst_b_addr;

	logic	[31:0]	src_a_data;
	logic	[31:0]	src_b_data;

	logic	[2:0]	bus_src_sel;
	logic	[31:0]	data_bus;

	logic	[31:0]	a;
	logic	[31:0]	b;
	logic	[31:0]	immediate;

	logic	[31:0]	ALU_out;
	logic	[63:0]	MUL_out;
	logic	[31:0]	DIV_out;
	logic	[31:0]	FPU_out;

	logic	[31:0]	SR;
	logic	[31:0]	PC;

	// operation control
	logic			load_MUL;
	logic			load_DIV;
	logic			load_FPU;
	logic			load_MEM;
	logic			store_MEM;

	logic	[3:0]	ALU_OP;
	logic			MUL_OP;
	logic	[1:0]	DIV_OP;
	logic	[3:0]	FPU_OP;
	logic	[2:0]	FPU_RM;
	logic	[3:0]	JMP_OP;

	logic			ready_MUL;
	logic			ready_DIV;
	logic			ready_FPU;

	logic			write_ALU_flags;
	logic			write_FPU_flags;

	logic			jump_ena;
	logic			jump;

	logic			sel_imm;
	logic			float_cmp;

	// control unit + instruction decoder
	logic	[3:0]	step_counter;
	logic	[31:0]	instruction;

	logic			fetch_imm;
	logic			ready;
	logic			next_step;
	logic			stall;
	
	// interrupt control
	logic			int_req;
	logic	[31:0]	isr_ptr;
	logic			int_taken;
	logic			int_ack;
	logic			ret_int;
	logic			wait_int;

	// flag control
	logic			GIE;
	logic			set_GIE;
	logic			clr_GIE;

	// ALU flags
	logic			ALU_C;	logic	C_flag;
	logic			ALU_Z;	logic	Z_flag;
	logic			ALU_N;	logic	N_flag;
	logic			ALU_V;	logic	V_flag;
	logic			ALU_S;	logic	S_flag;

	// FPU flags
	logic			IV;
	logic			DZ;
	logic			OF;
	logic			UF;
	logic			IE;

	logic			greater;
	logic			equal;
	logic			less;
	logic			unordered;

	logic			FPU_C;	assign	FPU_C = less;
	logic			FPU_Z;	assign	FPU_Z = equal;
	logic			FPU_N;	assign	FPU_N = less;
	logic			FPU_V;	assign	FPU_V = unordered;
	logic			FPU_S;	assign	FPU_S = less || unordered;

	// src a, b multiplexer
	always_comb begin
		case (src_a_addr)
		`SR:		a = SR;
		`PC:		a = PC;
		default:	a = src_a_data;
		endcase

		if (!src_b_ena)
			b = 32'h00000000;

		else if (sel_imm)
			b = immediate;

		else begin
			case (src_b_addr)
			`SR:		b = SR;
			`PC:		b = PC;
			default:	b = src_b_data;
			endcase
		end
	end

	// data bus source multiplexer
	always_comb begin
		case (bus_src_sel)
		`SEL_REG:	case (src_b_addr)
					`SR:		data_bus = SR;
					`PC:		data_bus = PC;
					default:	data_bus = src_b_data;
					endcase
		`SEL_MULL:	data_bus = MUL_out[31:0];
		`SEL_MULH:	data_bus = MUL_out[63:32];
		`SEL_DIV:	data_bus = DIV_out;
		`SEL_FPU:	data_bus = FPU_out;
		`SEL_MEM:	data_bus = dmem_din;
		default:	data_bus = ALU_out;
		endcase
	end

	// memory controller
	always_comb begin
		if (store_MEM) begin
			write		= 1'b1;
			dmem_addr	= ALU_out;
		end

		else if (load_MEM) begin
			write		= 1'b0;
			dmem_addr	= ALU_out;
		end

		else begin
			write		= 1'b0;
			dmem_addr	= 32'h00000000;
		end
	end

	assign	dmem_dout = write ? data_bus : 32'h00000000;

	// interrupt priority encoder
	always_comb begin
		if (int0)
			isr_ptr = `ISR0;

		else if (int1)
			isr_ptr = `ISR1;

		else if (int2)
			isr_ptr = `ISR2;

		else if (int3)
			isr_ptr = `ISR3;

		else if (int4)
			isr_ptr = `ISR4;

		else if (int5)
			isr_ptr = `ISR5;

		else if (int6)
			isr_ptr = `ISR6;

		else if (int7)
			isr_ptr = `ISR7;

		else
			isr_ptr = 32'h00000000;
	end

	assign 	int_req =
		int0 || int1 || int2 || int3 ||
		int4 || int5 || int6 || int7;

	always_ff @(negedge clk, posedge reset) begin
		if (reset)
			ready <= 1'b0;

		else
			ready <= ready_MUL || ready_DIV || ready_FPU;
	end

	// module instantiations
	register_file register_file_inst
	(
		.clk(clk),
		.reset(reset),

		.write_a(write_dst_a),
		.dst_a_addr(dst_a_addr),
		.dst_a_data(data_bus),

		.write_b(write_dst_b),
		.dst_b_addr(dst_b_addr),
		.dst_b_data(MUL_out[63:32]),

		.src_a_addr(src_a_addr),
		.src_a_data(src_a_data),

		.src_b_addr(src_b_addr),
		.src_b_data(src_b_data)
	);

	ALU ALU_inst
	(
		.op(ALU_OP),
		.C_in(C_flag),

		.a(a),
		.b(b),

		.y(ALU_out),
		.C(ALU_C),
		.Z(ALU_Z),
		.N(ALU_N),
		.V(ALU_V),
		.S(ALU_S)
	);

	int_multiplier #(32, 8) int_multiplier_inst
	(
		.clk(clk),
		.reset(reset),
		.load(load_MUL),

		.op(MUL_OP),

		.a(a),
		.b(b),

		.y(MUL_out),

		.ready(ready_MUL)
	);

	int_divider #(32, 8) int_divider_inst
	(
		.clk(clk),
		.reset(reset),
		.load(load_DIV),

		.op(DIV_OP),

		.a(a),
		.b(b),

		.y(DIV_out),

		.ready(ready_DIV)
	);

	FPU FPU_inst
	(
		.clk(clk),
		.reset(reset),
		.load(load_FPU),

		.op(FPU_OP),
		.rm(FPU_RM),

		.a(a),
		.b(b),

		.result(FPU_out),

		.IV(IV),
		.DZ(DZ),
		.OF(OF),
		.UF(UF),
		.IE(IE),

		.greater(greater),
		.equal(equal),
		.less(less),
		.unordered(unordered),

		.ready(ready_FPU)
	);

	status_register status_register_inst
	(
		.clk(clk),
		.reset(reset),

		.SR_in(data_bus),
		.SR_out(SR),

		// control signals
		.write(write_dst_a && dst_a_addr == `SR),
		.write_ALU(write_ALU_flags),
		.write_FPU(write_FPU_flags),

		.set_GIE(set_GIE),
		.clr_GIE(clr_GIE),

		.int_taken(int_taken),
		.int_ack(int_ack),
		.ret_int(ret_int),
		.wait_int(wait_int),

		// ALU flags
		.C(float_cmp ? FPU_C : ALU_C),
		.N(float_cmp ? FPU_N : ALU_N),
		.Z(float_cmp ? FPU_Z : ALU_Z),
		.V(float_cmp ? FPU_V : ALU_V),
		.S(float_cmp ? FPU_S : ALU_S),

		// FPU flags
		.IV(IV),
		.DZ(DZ),
		.OF(OF),
		.UF(UF),
		.IE(IE),

		.C_flag(C_flag),
		.N_flag(N_flag),
		.Z_flag(Z_flag),
		.V_flag(V_flag),
		.S_flag(S_flag),

		.GIE(GIE)
	);

	jump_logic jump_logic_inst
	(
		.C(C_flag),
		.Z(Z_flag),
		.N(N_flag),
		.V(V_flag),
		.S(S_flag),

		.ena(jump_ena),
		.con(JMP_OP),
		.jump(jump)
	);

	control_unit control_unit_inst
	(
		.clk(clk),
		.reset(reset),

		.imem_addr(imem_addr),
		.imem_din(imem_din),

		.jump((write_dst_a && dst_a_addr == `PC) || jump),
		.addr(data_bus),
		.PC(PC),

		.GIE(GIE),
		.int_req(int_req),
		.isr_ptr(isr_ptr),
		.int_taken(int_taken),
		.int_ack(int_ack),
		.ret_int(ret_int),
		.wait_int(wait_int),
		.CPU_halt(CPU_halt),

		.stall(stall),
		.next_step(next_step),
		.fetch_imm(fetch_imm),

		.IR(instruction),
		.IM(immediate),
		.SC(step_counter)
	);

	inst_decoder inst_decoder_inst
	(
		// control unit signals
		.step_counter(step_counter),
		.instruction(instruction),

		.fetch_imm(fetch_imm),
		.ready(ready),
		.next_step(next_step),
		.stall(stall),

		.ret_int(ret_int),
		.wait_int(wait_int),

		// CPU control signals
		.src_a_addr(src_a_addr),
		.src_b_addr(src_b_addr),
		.dst_a_addr(dst_a_addr),
		.dst_b_addr(dst_b_addr),
		.ALU_OP(ALU_OP),
		.MUL_OP(MUL_OP),
		.DIV_OP(DIV_OP),
		.FPU_OP(FPU_OP),
		.FPU_RM(FPU_RM),
		.JMP_OP(JMP_OP),

		.bus_src_sel(bus_src_sel),
		.write_dst_a(write_dst_a),
		.write_dst_b(write_dst_b),

		.write_ALU_f(write_ALU_flags),
		.write_FPU_f(write_FPU_flags),

		.jump_ena(jump_ena),
		.src_b_ena(src_b_ena),
		.sel_imm(sel_imm),
		.float_cmp(float_cmp),

		.load_MUL(load_MUL),
		.load_DIV(load_DIV),
		.load_FPU(load_FPU),

		.load_MEM(load_MEM),
		.store_MEM(store_MEM),

		.set_GIE(set_GIE),
		.clr_GIE(clr_GIE)
	);

endmodule