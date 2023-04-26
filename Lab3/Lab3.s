.equ JTAG_UART_BASE,	0x10001000
.equ DATA_OFFSET,		0
.equ STATUS_OFFSET,		4
.equ WSPACE_MASK,		0xFFFF

.text
.global _start
.org 0x0000

_start:

	movia sp, 0x007FFFFC
	
	#movia r2, START
	#call PrintString
	
	#Part1
	movia r2, LIST
	ldw   r4, N(r0)
	call  ShowByteList
	
	#movia r2, LAB3
	#call PrintString
	#-----
	#movia r3, MID
	#call PrintString
	#-----
	
	#Part2
	movia r2, LIST
	ldw r3, N(r0)
	ldw r4, AMT(r0)
	call  DecreaseByteList
	
	movia r2, LIST
	ldw   r4, N(r0)
	call  ShowByteList
	
	movi r2, '\n'
	call PrintChar
	
_end:
	break
	
PrintChar:
	subi sp, sp, 8	#adjust stack pointer down to the reserve space
	stw r3, 4(sp)	#save value of register r3 so it can be temp
	stw r4, 0(sp)	#save value of register r4 so it can be temp
	movia r3, JTAG_UART_BASE	#point to first memory-mapped I/O register
pc_loop:
	ldwio r4, STATUS_OFFSET(r3)	#read bits from status register
	andhi r4, r4, WSPACE_MASK	#mask off lower bits to isolate upper bits
	beq r4, r0, pc_loop			#if upper bits are 0, loop again
	stwio r2, DATA_OFFSET(r3)	#otherwise, write character to data register
	ldw r3, 4(sp)	#restor value of r3 from stack
	ldw r4, 0(sp)	#restor value of r4 from stack
	addi sp, sp, 8	#read just stack pointer up to deallocate space
	ret				#return to calling routine

PrintString:
	subi sp, sp, 8
	stw r2, 4(sp)
	stw ra, 0(sp)
ps_loop:
	ldb r2, 0(r3)
ps_if:
	beq r2, r0, ps_end_loop
	call PrintChar
	addi r3, r3, 1
	br ps_loop
ps_end_if:
ps_end_loop:
	movi r2, '\n'
	call PrintChar
	ldw ra, 0(sp)
	ldw r2, 4(sp)
	addi sp, sp, 8
	ret

PrintHexDigit:
 	subi sp, sp, 12
 	stw r2, 8(sp)
 	stw r3, 4(sp)
 	stw ra, 0(sp)
phd_if:
	movi r3, 10
	bge r2, r3, phd_else
phd_then:
	addi r2, r2, '0'
	br phd_end_if
phd_else:
	subi r2, r2, 10
	addi r2, r2, 'A'
phd_end_if:
	call PrintChar
	ldw ra, 0(sp)
	ldw r3, 4(sp)
	ldw r2, 8(sp)
	addi sp, sp, 12
	ret

PrintHexByte:
	subi sp, sp, 12
	stw r2, 8(sp)
	stw r3, 4(sp)
	stw ra, 0(sp)
	
	mov r3, r2
	srai r2, r3, 4
	call PrintHexDigit
	andi r2, r3, 0xF
	call PrintHexDigit
	
	#movi r2, '\n'
	#call PrintChar
	
	ldw ra, 0(sp)
	ldw r3, 4(sp)
	ldw r2, 8(sp)
	addi sp, sp, 12
	ret

#Part1
ShowByteList:
	subi sp, sp, 16
	stw r2, 12(sp) #list
	stw r4, 8(sp) #n 
	stw r3, 4(sp)
	stw ra, 0(sp)
	mov r3, r2
SBL_IF:
SBL_LOOP:
	ble r4, r0, SBL_END
	
	movi r2, '0'
	call PrintChar
	movi r2, 'x'
	call PrintChar
	
	ldbu r2, 0(r3)
	call PrintHexByte
	movi r2, ''
	
	addi r3, r3, 1
	subi r4, r4, 1
	bgt	 r4, r0, SBL_LOOP
	
SBL_END:
	movi r2, '\n'
	call PrintChar
	ldw  ra, 0(sp)
	ldw  r3, 4(sp)
	ldw  r4, 8(sp)
	ldw  r2, 4(sp)
	addi sp, sp, 16
	ret

#Part2
DecreaseByteList:
	subi sp,sp,16
	stw r2,12(sp) #list
	stw r3,8(sp) #n
	stw r4,4(sp) #amt
	stw r5,0(sp)
	dbl_loop:
	ldbu r5, 0(r2)
	sub r5,r5,r4
	stb r5,0(r2)
	addi r2,r2,1
	subi r3,r3,1
	beq r3,r0,dbl_end_loop
	br dbl_loop
	dbl_end_loop:
	ldw r5,0(sp)
	ldw r4,4(sp)
	ldw r3,8(sp)
	ldw r2,12(sp)
	addi sp,sp,16
	ret
	
.org 0x1000
LIST:		.byte 0x2C, 0xE8, 0xF4, 0x75
N:			.word 4
AMT:		.word 3

#LAB3:	.asciz "Lab 3\n"
#START:	.asciz "START"
#MID:	.asciz "****"
#END:	.asciz "END"

.end
