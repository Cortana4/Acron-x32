module status_register
(
	input	logic			clk,
	input	logic			reset,

	input	logic	[31:0]	SR_in,
	output	logic	[31:0]	SR_out,

	// control signals
	input	logic			write,
	input	logic			write_ALU,
	input	logic			write_FPU,

	input	logic			set_GIE,
	input	logic			clr_GIE,

	input	logic			int_taken,
	input	logic			int_ack,
	input	logic			ret_int,
	input	logic			wait_int,

	// ALU flags
	input	logic			C,
	input	logic			N,
	input	logic			Z,
	input	logic			V,
	input	logic			S,

	// FPU flags
	input	logic			IV,
	input	logic			DZ,
	input	logic			OF,
	input	logic			UF,
	input	logic			IE,

	output	logic			C_flag,
	output	logic			N_flag,
	output	logic			Z_flag,
	output	logic			V_flag,
	output	logic			S_flag,

	output	logic			GIE
);

	logic	IV_flag;
	logic	DZ_flag;
	logic	OF_flag;
	logic	UF_flag;
	logic	IE_flag;

	logic	GIE_flag;

	logic	C_flag_din;
	logic	N_flag_din;
	logic	Z_flag_din;
	logic	V_flag_din;
	logic	S_flag_din;

	logic	IV_flag_din;
	logic	DZ_flag_din;
	logic	OF_flag_din;
	logic	UF_flag_din;
	logic	IE_flag_din;

	logic	GIE_din;

	logic	ALU_ena;
	logic	FPU_ena;
	logic	GIE_ena;

	assign	ALU_ena	= write || write_ALU;
	assign	FPU_ena	= write || write_FPU;

	assign	SR_out	=
			{
				15'h0000,
				GIE_flag,
				3'b000,
				IE_flag,
				UF_flag,
				OF_flag,
				DZ_flag,
				IV_flag,
				3'b000,
				S_flag,
				V_flag,
				Z_flag,
				N_flag,
				C_flag
			};

	always_ff @(posedge clk, posedge reset) begin
		if (reset) begin
			C_flag		<= 1'b0;
			N_flag		<= 1'b0;
			Z_flag		<= 1'b0;
			V_flag		<= 1'b0;
			S_flag		<= 1'b0;
			IV_flag		<= 1'b0;
			DZ_flag		<= 1'b0;
			OF_flag		<= 1'b0;
			UF_flag		<= 1'b0;
			IE_flag		<= 1'b0;
			GIE_flag	<= 1'b0;
		end

		else begin
			if (ALU_ena) begin
				C_flag		<= C_flag_din;
				N_flag		<= N_flag_din;
				Z_flag		<= Z_flag_din;
				V_flag		<= V_flag_din;
				S_flag		<= S_flag_din;
			end

			if (FPU_ena) begin
				IV_flag		<= IV_flag_din;
				DZ_flag		<= DZ_flag_din;
				OF_flag		<= OF_flag_din;
				UF_flag		<= UF_flag_din;
				IE_flag		<= IE_flag_din;
			end

			if (GIE_ena)
				GIE_flag	<= GIE_din;
		end
	end

	// ALU flags
	always_comb begin
		if (write) begin
			C_flag_din	= SR_in[0];
			N_flag_din	= SR_in[1];
			Z_flag_din	= SR_in[2];
			V_flag_din	= SR_in[3];
			S_flag_din	= SR_in[4];

		end

		else begin
			C_flag_din	= C;
			N_flag_din	= N;
			Z_flag_din	= Z;
			V_flag_din	= V;
			S_flag_din	= S;
		end
	end

	// FPU flags
	always_comb begin
		if (write) begin
			IV_flag_din	= SR_in[8];
			DZ_flag_din	= SR_in[9];
			OF_flag_din	= SR_in[10];
			UF_flag_din	= SR_in[11];
			IE_flag_din	= SR_in[12];
		end

		else begin
			IV_flag_din	= IV;
			DZ_flag_din	= DZ;
			OF_flag_din	= OF;
			UF_flag_din	= UF;
			IE_flag_din	= IE;
		end
	end

	// global interrupt enable
	always_comb begin
		GIE_ena	= 1'b1;
		GIE		= GIE_flag;

		if (!int_ack) begin
			if (write) begin
				GIE_din	= SR_in[16];
				GIE		= GIE_din;
			end

			else if (clr_GIE) begin
				GIE_din	= 1'b0;
				GIE		= 1'b0;
			end

			else if (set_GIE) begin
				GIE_din	= 1'b1;
				GIE		= 1'b1;
			end

			else if (int_taken)
				GIE_din	= 1'b0;

			else if (wait_int)
				GIE_din	= 1'b1;

			else begin
				GIE_din	= 1'b0;
				GIE_ena	= 1'b0;
			end
		end

		else if (ret_int)
			GIE_din	= 1'b1;

		else begin
			GIE_din	= 1'b0;
			GIE_ena	= 1'b0;
		end
	end

endmodule