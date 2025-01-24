;
; lab2.asm
;
; Created: 2025-01-24 11:31:58 AM
; Author : dryd3n
;
.cseg
.org 0

.def number = r16
	
	ldi number, 0x0A
	;opcode 0111 kkkk dddd kkkk
	;		1110 0000 0000 1010
	;       15   0    0    10
	;       a    0    0    e
	;       a0 0e
	;       0e a0

	andi number, 0b00000001
	;opcode 0111 kkkk dddd kkkk
	;       0111 0000 0000 0001
	;       7    0    0    1
	;       70 01
	;       01 70

	end: 
	jmp end ;end with infinite loop
