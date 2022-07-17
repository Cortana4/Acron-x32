// FPU functions
`define FPU_OP_ADD		4'd0
`define FPU_OP_SUB		4'd1
`define FPU_OP_MUL		4'd2
`define FPU_OP_DIV		4'd3
`define FPU_OP_SQRT		4'd4
`define FPU_OP_NEG		4'd5
`define FPU_OP_ABS		4'd6
`define FPU_OP_CVTFI	4'd7
`define FPU_OP_CVTFU	4'd8
`define FPU_OP_CVTIF	4'd9
`define FPU_OP_CVTUF	4'd10
`define FPU_OP_CMP		4'd11

// FPU rounding modes
`define FPU_RM_RNE		3'd0	// round to nearest (tie to even)
`define FPU_RM_RMM		3'd1	// round to nearest (tie to max magnitude)
`define FPU_RM_RTZ		3'd2	// round towards 0 (truncate)
`define FPU_RM_RDN		3'd3	// round down (towards -inf)
`define FPU_RM_RUP		3'd4	// round up (towards +inf)