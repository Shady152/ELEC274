.equ JTAG_UART_BASE,	0x10001000
.equ DATA_OFFSET,		0
.equ STATUS_OFFSET,		4
.equ WSPACE_MASK,		0xFFFF

.text
.global _start
.org 0x0000

_start:
	movia sp, 0x007FFFFC
	
	movia r3, INITIAL
	call PrintString
	
	movi r2, '\n'
	call PrintChar
	movi r2, '2'
	call PrintChar
	movi r2, '7'
	call PrintChar
	movi r2, '4'
	call PrintChar
	
	movi r2, '\n'
	call PrintChar
	movia r3, SEPERATE
	call PrintString
	
	
	movia r3, TXT1
	call PrintString
	movia r3, TXT2
	call PrintString
	movia r3, TXT3
	call PrintString
	movia r3, TXT4
	call PrintString
	
	movi r2, '\n'
	call PrintChar
	movia r3, SEPERATE
	call PrintString
	
	movi r2, 5
	call PrintHexDigit
	
	movi r2, '\n'
	call PrintChar
	
	movi r2, 10
	call PrintHexDigit
	
	movi r2, '\n'
	call PrintChar
	
	movi r2, 110
	call PrintHexByte
	
	movia r3, INITIAL
	call PrintString
	
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
	
	movi r2, '\n'
	call PrintChar
	
	ldw ra, 0(sp)
	ldw r3, 4(sp)
	ldw r2, 8(sp)
	addi sp, sp, 12
	ret
	
.org 0x1000
TXT1:.asciz "Hello World!"
TXT2:.asciz "This is easy"
TXT3:.asciz "This works"
TXT4:.asciz "It is the end"
INITIAL:.asciz "####"
SEPERATE:.asciz "****"

.end





