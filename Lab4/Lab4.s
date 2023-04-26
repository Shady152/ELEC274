.equ	JTAG_UART_BASE,	0x10001000	#address of first JTAG UART register
.equ	DATA_OFFSET,	0			#offset of JTAG UART data register
.equ	STATUS_OFFSET,	4			#offset of JTAG UART status register
.equ	WSPACE_MASK,	0xFFFF		#used in AND operation to check status

.text
.global _start
.org	0x0000

_start:
	movia	sp, 0x7FFFFC
	
	movia	r2, TEXT
	call	PrintString
	
	ldw		r3, N(r0)
	movia	r4, LIST
	movi	r6, 0x56
	movia	r7, 0xFFFFFFFF
	movia	r8, 0x01010101
	
loop:
	call	GetChar
	mov		r5, r2
	call	PrintChar
	movi	r2, ' '
	call	PrintChar
	mov		r2, r5
	call	PrintHexByte
	movi	r2, '\n'
	call	PrintChar
	
if:
	bne		r5, r6, if_else
if_then:
	stw		r7, 0(r4)
	br		if_end
if_else:
	stw		r8, 0(r4)
if_end:
	
	addi	r4, r4, 4
	subi	r3, r3, 1
	bgt		r3, r0, loop
	
	break
	
#--------------------------------------------------------------------------------

PrintChar:
	subi	sp, sp, 8
	stw		r3, 4(sp)
	stw		r4, 0(sp)
	movia	r3, JTAG_UART_BASE
pc_loop:
	ldwio	r4, STATUS_OFFSET(r3)
	andhi	r4, r4, WSPACE_MASK
	beq		r4, r0, pc_loop
	stwio	r2, DATA_OFFSET(r3)
	ldw		r3, 4(sp)
	ldw		r4, 0(sp)
	addi	sp, sp, 8
	ret
	
	
#--------------------------------------------------------------------------------

GetChar:
	subi	sp, sp, 8
	stw		r3, 4(sp)
	stw		r4, 0(sp)
	
	movia	r2, JTAG_UART_BASE

gc_do:
	ldwio	r3, DATA_OFFSET(r2)
	andi	r4, r3, 0x8000
	beq		r4, r0, gc_do
gc_end_loop:
	andi	r2, r3, 0xFF
	
	ldw		r3, 4(sp)
	ldw		r4, 0(sp)
	addi	sp, sp, 8
	
	ret
	
#--------------------------------------------------------------------------------

PrintHexDigit:
	subi	sp, sp, 12
	stw		r2, 8(sp)
	stw		r3, 4(sp)
	stw		ra, 0(sp)
	
phd_if:
	movi	r3, 10
	bge		r2, r3, phd_else
phd_then:
	addi	r2, r2, '0'
	br		phd_end_if
phd_else:
	subi	r2, r2, 10
	addi	r2, r2, 'A'
phd_end_if:
	call	PrintChar
	
	ldw		r2, 8(sp)
	ldw		r3, 4(sp)
	ldw		ra, 0(sp)
	addi	sp, sp, 12
	
	ret
	
#--------------------------------------------------------------------------------	

PrintHexByte:
	subi	sp, sp, 12
	stw		r2, 8(sp)
	stw		r3, 4(sp)
	stw		ra, 0(sp)
	
	mov		r3, r2
	srli	r2, r3, 4
	call	PrintHexDigit
	
	andi	r2, r3, 0xF
	call	PrintHexDigit
	
	ldw		r2, 8(sp)
	ldw		r3, 4(sp)
	ldw		ra, 0(sp)
	addi	sp, sp, 12
	
	ret
	
#--------------------------------------------------------------------------------

PrintHexWord:
	subi	sp, sp, 12
	stw		r2, 8(sp)
	stw		r3, 4(sp)
	stw		ra, 0(sp)
	
	mov		r3, r2
	
	srli	r2, r3, 24
	call	PrintHexByte
	
	srli	r2, r3, 16
	andi	r2, r2, 0xFF
	call	PrintHexByte
	
	srli	r2, r3, 8
	andi	r2, r2, 0xFF
	call	PrintHexByte
	
	andi	r2, r3, 0xFF
	call	PrintHexByte

	ldw		r2, 8(sp)
	ldw		r3, 4(sp)
	ldw		ra, 0(sp)
	addi	sp, sp, 12
	
	ret
	
#--------------------------------------------------------------------------------
PrintString:
	subi	sp, sp, 12
	stw		r2, 8(sp)
	stw		r3, 4(sp)
	stw		ra, 0(sp)

	mov		r3, r2
ps_loop:
	ldb		r2, 0(r3)
ps_if:
	beq		r2, r0, ps_end_loop
	
ps_end_if:
	call	PrintChar
	addi	r3, r3, 1
	br		ps_loop
ps_end_loop:

	ldw		r2, 8(sp)
	ldw		r3, 4(sp)
	ldw		ra, 0(sp)
	addi	sp, sp, 12
	
	ret

.org	0x1000
N:		.word	4
LIST:	.skip	16


.org	0x1090
TEXT:	.asciz	"Lab 4\n"

.end





