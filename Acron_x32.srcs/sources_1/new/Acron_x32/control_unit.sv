module control_unit
(
	input	logic			clk,
	input	logic			reset,

	output	logic	[31:0]	imem_addr,
	input	logic	[31:0]	imem_din,

	input	logic			jump,
	input	logic	[31:0]	addr,
	output	logic	[31:0]	PC,

	input	logic			GIE,
	input	logic			int_req,
	input	logic	[31:0]	isr_ptr,
	output	logic			int_taken,
	output	logic			int_ack,
	input	logic			ret_int,
	input	logic			wait_int,
	output	logic			CPU_halt,

	input	logic			stall,
	input	logic			next_step,
	output	logic			fetch_imm,

	output	logic	[31:0]	IR,
	output	logic	[31:0]	IM,
	output	logic	[3:0]	SC
);

	logic	[31:0]	ret_addr;
	logic	[31:0]	jmp_addr;

	logic			fetched;

	logic			jump_int;

	logic			Wait;
	logic			halt;
	
	assign			jump_int	= jump || ret_int || int_taken;
	assign			Wait		= wait_int && !int_ack && !int_taken;
	assign			halt		= CPU_halt || Wait;
	assign			fetch_imm	= IR[26] && !fetched;
	assign			int_taken	= int_req && !ret_int && GIE && !jump && !fetch_imm && !next_step && !stall;

	// jump address multiplexer
	always_comb begin
		if (ret_int)
			jmp_addr = ret_addr;

		else if (int_taken)
			jmp_addr = isr_ptr;

		else if (halt)
			jmp_addr = PC - 32'd1;

		else
			jmp_addr = addr;
	end

	// program counter
	always_ff @(posedge clk, posedge reset) begin
		if (reset)
			PC <= 32'h00000000;

		// jump
		else if (jump_int)
			PC <= jmp_addr + 32'd1;

		// wait
		else if (!(next_step || stall || halt))
			PC <= PC + 32'd1;
	end

	// program counter bypass
	always_comb begin
		if (jump_int || halt)
			imem_addr = jmp_addr;

		else
			imem_addr = PC;
	end

	// instruction register, immediate and step counter
	always_ff @(negedge clk, posedge reset) begin
		if (reset) begin
			IR		<= 32'h00000000;
			IM		<= 32'h00000000;
			SC		<= 4'h0;
			fetched	<= 1'b0;
		end

		else if (fetch_imm) begin
			IM		<= imem_din;
			fetched	<= 1'b1;
		end

		else if (next_step)
			SC		<= SC + 4'd1;

		else if (!stall) begin
			IR		<= imem_din;
			IM		<= 32'h00000000;
			SC		<= 4'h0;
			fetched	<= 1'b0;
		end
	end

	// interrupt return address
	always_ff @(posedge clk, posedge reset) begin
		if (reset)
			ret_addr	<= 32'h00000000;

		else if (int_taken)
			ret_addr	<= PC;
	end

	// flag control
	always_ff @(posedge clk, posedge reset) begin
		if (reset) begin
			int_ack		<= 1'b0;
			CPU_halt	<= 1'b0;
		end

		else if (ret_int)
			int_ack		<= 1'b0;

		else if (int_taken) begin
			int_ack		<= 1'b1;
			CPU_halt	<= 1'b0;
		end

		else if (Wait)
			CPU_halt	<= 1'b1;
	end

endmodule