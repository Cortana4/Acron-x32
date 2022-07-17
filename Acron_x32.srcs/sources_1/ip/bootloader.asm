.inc	"Acron_x32.asm"
.org	[BOOT_ROM]

inr		sp, STACK					; init stack pointer

ldm		r1,	[MODE_SW]				; read prog switch
cmp		r1,	r0						; check mode
mov		r0, r1						; clear r1
jeq		[INST_MEM]					; run mode

; prog mode
prog:
	ldm		r1, [UART_RX_STAT_REG]	; read rx status register
	and		r1, 0x000000FF			; mask rx_size
	cmp		r1, 4					; check if word is available
	jlo		prog					; rx_size < 4: wait for data

	; rx_size >= 4: read data
	ldm		r1, [UART_DATA]
	ldm		r2, [UART_DATA]
	lsl		r2, 8
	ldm		r3, [UART_DATA]
	lsl		r3, 16
	ldm		r4, [UART_DATA]
	lsl		r4, 24

	; concatenate 4 bytes to word
	or		r1, r2
	or		r1, r3
	or		r1, r4

	; store word in memory
	stm		r1, [INST_MEM + r5]
	inc		r5
	cmp		r5, 4096				; check if entire data has been received
	jlo		prog					; received words < 4096: wait for next word

	; received words >= 4096: check rx status
	ldm		r1, [UART_RX_STAT_REG]	; read rx status register
	and		r1, 0x00F80000			; mask error flags
	lsr		r1, 19
	stm		r1, [UART_DATA]			; send back rx status
	wait