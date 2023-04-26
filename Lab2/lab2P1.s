
.text
.global _start
.org 0x0000
_start:
	movia sp, 0x7FFFFC
	 movia r2, LIST1
	 movia r3, LIST2
	 ldw r4, N(r0) #N
	 ldw r5, FACTOR(r0)
	 call Compute
	 stw r2, RESULT(r0)
	 
_end:
	break

Compute:
	subi sp, sp, 28
	stw r3, 24(sp)
	stw r9, 20(sp)
	stw r4, 16(sp)
	stw r7, 12(sp)
	stw r5, 8(sp)
	stw r6, 4(sp)
	stw r8, 0(sp)
	movi r8, 5
	mov r6, r0 #count
	
	com_loop:
	com_if:
		ldw r7, 0(r2)
		ldw r9, 0(r3)
		bge r7, r8, com_else
	com_then:
		mul r9, r7, r5 
		stw r9, 0(r3)
		addi r6, r6, 1
		br com_end_if
	com_else:
		stw r0, 0(r3)
		#muli r9, r9, 0
	com_end_if:
		addi r2, r2, 4
		addi r3, r3, 4
		subi r4, r4, 1
		bgt r4, r0, com_loop
		mov r2, r6
		ldw r8, 0(sp)
		ldw r6, 4(sp)
		ldw r5, 8(sp)
		ldw r7, 12(sp)
		ldw r4, 16(sp)
		ldw r9, 20(sp)
		ldw r3, 24(sp)
		addi sp, sp, 28
	ret

.org 0x1000
LIST1: .word 4,5,6
LIST2: .word 1,1,1
N:		.word 3
FACTOR: .word 2
RESULT: .skip 4
		.end
