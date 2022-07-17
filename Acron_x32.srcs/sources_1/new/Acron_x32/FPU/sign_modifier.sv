module sign_modifier
(
	input	logic			clk,
	input	logic			reset,
	input	logic			load,
	
	input	logic			neg,
	input	logic			abs,

	input	logic	[31:0]	float_in,
	output	logic	[31:0]	float_out,
	
	output	logic			ready
);

	always_ff @(posedge clk, posedge reset) begin
		if (reset || (load && !(neg || abs))) begin
			float_out	<= 32'h00000000;
			ready		<= 1'b0;
		end
		
		else if (load) begin
			if (neg) begin
				float_out	<= {!float_in[31], float_in[30:0]};
				ready		<= 1'b1;
			end

			else if (abs) begin
				float_out	<= {1'b0, float_in[30:0]};
				ready		<= 1'b1;
			end
		end
		
		else
			ready		<= 1'b0;
	end

endmodule