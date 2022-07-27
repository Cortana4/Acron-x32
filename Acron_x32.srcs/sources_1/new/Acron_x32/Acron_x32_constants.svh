//******************************
// ALU functions
`define	ALU_ADD		4'd0
`define	ALU_ADC		4'd1
`define	ALU_SUB		4'd2
`define	ALU_SBC		4'd3
`define	ALU_INC		4'd4
`define	ALU_DEC		4'd5
`define	ALU_NEG		4'd6
`define	ALU_AND		4'd7
`define	ALU_OR		4'd8
`define	ALU_XOR		4'd9
`define	ALU_NOT		4'd10
`define	ALU_LSL		4'd11
`define	ALU_LSR		4'd12
`define ALU_ASR		4'd13
`define	ALU_ROR		4'd14
`define	ALU_RRX		4'd15


//******************************
// MUL functions
`define UMUL		1'd0
`define	SMUL		1'd1


//******************************
// DIV functions
`define UDIV		2'd0
`define SDIV		2'd1
`define	UMOD		2'd2
`define	SMOD		2'd3


//******************************
// jump conditions
`define JMP_EQ		4'd1
`define JMP_NE		4'd2
`define JMP_HI		4'd3
`define JMP_SH		4'd4
`define JMP_SL		4'd5
`define JMP_LO		4'd6
`define JMP_GT		4'd7
`define JMP_GE		4'd8
`define JMP_LE		4'd9
`define JMP_LT		4'd10
`define JMP_MI		4'd11
`define JMP_PL		4'd12
`define JMP_VS		4'd13
`define JMP_VC		4'd14
`define JMP_AL		4'd15


//******************************
// data bus src sel
`define SEL_ALU		3'd0
`define SEL_REG		3'd1
`define SEL_MULL	3'd2
`define SEL_MULH	3'd3
`define SEL_DIV		3'd4
`define SEL_FPU		3'd5
`define SEL_MEM		3'd6


//******************************
// special registers
`define SP			6'd61
`define SR			6'd62
`define PC			6'd63


//******************************
// opcodes
`define	NOP			5'd0
`define	INR			5'd1
`define	MOV			5'd2
`define	STM			5'd3
`define	LDM			5'd4
`define	PUSH		5'd5
`define	POP			5'd6
`define ALU			5'd7
`define MUL			5'd8
`define DIV			5'd9
`define FPU			5'd10
`define JMP			5'd11
`define	IEN			5'd12
`define	IDI			5'd13
`define	WAIT		5'd14
`define	RETI		5'd15
`define	CALL		5'd16
`define	RET			5'd17


//******************************
// memory map						// CPU (inst)	// CPU (data)
`define	ROM_BEG		32'h00000000	// r			// r
`define ROM_END		32'h00000fff
`define RAM_BEG		32'h00001000	// r			// rw
`define RAM_END		32'h00002fff
`define	UART_BEG	32'h00003000	// -			// rw
`define	UART_END	32'h00003009
`define MODE_SW		32'h0000300a	// -			// r


//******************************
// interupt service routines
`define	ISR0		32'h00001ff0
`define	ISR1		32'h00001ff2
`define	ISR2		32'h00001ff4
`define	ISR3		32'h00001ff6
`define	ISR4		32'h00001ff8
`define	ISR5		32'h00001ffa
`define	ISR6		32'h00001ffc
`define	ISR7		32'h00001ffe