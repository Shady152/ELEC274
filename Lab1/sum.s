.text
.global _start
.org 0x0000

_start:
	ldw r2, N(r0)
	movi r3, LIST
	movi r4, 0
	
LOOP:
	ldw r5, 0(r3)
	add r4, r4, r5
	addi r3, r3, 4
	subi r2, r2, 1
	bgt r2, r0, LOOP
	
	stw r4, SUM(r0)
	
_end:
	br _end
	
#--------------------------------

		.org 0x1000
SUM:	.skip 4
N:		.word 5
LIST:	.word 12, 0xFFFFFFFE, 7, -1, 2

		.end

	