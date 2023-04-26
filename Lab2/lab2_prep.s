
.equ JTAG_UART_BASE,	0x10001000
.equ DATA_OFFSET,		0
.equ STATUS_OFFSET,		4
.equ WSPACE_MASK,		0xFFFF

.text
.global _start
.org 0x0000

_start:
	movia sp, 0x007FFFFC
	movi r2, '\n'
	call PrintChar
	movi r2, '2'
	call PrintChar
	movi r2, '7'
	call PrintChar
	movi r2, '4'
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
	
.end

