.equ JTAG_UART_BASE,	0x10001000
.equ DATA_OFFSET,		0
.equ STATUS_OFFSET,		4
.equ WSPACE_MASK,		0xFFFF

.text
.global _start
.org 0x0000

_start:
	
	movia sp, 0x7FFFFC
	
	movia r2, START
	call PrintString
	
	#movi r7, '0'
	
	#loop:
	#call GetChar
	#beq r2,r7,end_loop
	
	#call PrintChar
	#br loop
	#end_loop:
	#movi r2, '\n'
	#call PrintChar
	
	movi r2, BUFFER
	movi r3, 24
	call GetString
	
	#call PrintString
	
	movia r2, END
	call PrintString
	
_end:
	break


#------------------------------------------------------------------------------------

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
	ret		

PrintString: #Uses r3 in main
	subi sp, sp, 8
	stw r2, 4(sp)
	stw ra, 0(sp)
	mov r3,r2
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

#------------------------------------------------------------------------------------

GetChar:
	subi sp, sp, 8
	stw r4, 4(sp)
	stw r3, 0(sp)
	movia r3, JTAG_UART_BASE
gc_loop:
	ldwio r2, 0(r3) #read contents from the JTAG register
	andi r4, r2, 0x8000
	beq r4, r0, gc_loop
	
	andi r2, r2, 0xFF
	
	ldw r3, 0(sp)
	ldw r4, 4(sp)
	addi sp,sp,8
	ret

GetString:
	subi sp,sp,16
	stw ra, 12(sp)
	stw r3, 8(sp) #buffer
	stw r4, 4(sp)
	stw r5, 0(sp) #storing buffer
	#mov r3,r2
	#movi r3, 16 #max num of chars
	mov r5,r2
gs_loop:
	ble r5, r0, gs_end_loop
	ble r3, r0, gs_end_loop
	call GetChar
	call PrintChar
	cmpeqi r4, r2,'\n'
	bne r4, r0, gs_end_loop #end if u input return
	stb r2, 0(r5)
	addi r5,r5,1
	subi r3,r3,1
	br gs_loop
gs_end_loop:
	mov r2,r5
	#call PrintString
	ldw r5, 0(sp)
	ldw r4, 4(sp)
	ldw r3, 8(sp)
	ldw ra, 12(sp)
	addi sp,sp,16
	ret

.org 0x1000

START:	.asciz "LAB4\n"
END: .asciz "END OF PROGRAM"
BUFFER: .skip 32
#STRING: .word 32
.end
