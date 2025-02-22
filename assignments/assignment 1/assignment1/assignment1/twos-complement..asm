; twos-complement.asm
; CSC 230: Spring 2025
;
; Code provided for Assignment #1
; Author: Sudhakar Ganti
; 

; This skeleton of an assembly-language program is provided to help you
; begin with the programming task for A#1, part (c). In this and other
; files provided through the semester, you will see lines of code
; indicating "DO NOT TOUCH" sections. You are *not* to modify the
; lines within these sections. The only exceptions are for specific
; changes announced on conneX or in written permission from the course
; instructor. *** Unapproved changes could result in incorrect code
; execution during assignment evaluation, along with an assignment grade
; of zero. ****
;
; In a more positive vein, you are expected to place your code with the
; area marked "STUDENT CODE" sections.

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; Your task: You are to take the bit sequence stored in R16,
; and to find the rightmost bit that is set, keep all bits to the right
; of this bit (including this bit) intact and flip remaining
; by storing this new value in R17. For example, given
; the bit sequence 0b01011100, find the right-most set bit and
; fliiping bits to the left of this will produce 0b10100100.
; As another example, given the bit sequence 0b00110110,
; the result will be 0b11001010.
;
; Your solution must work, of course, for bit sequences other
; than those provided in the example. (How does your
; algorithm handle a value with no set bits? with all set bits?
; or if if it is already a negative number?)

; ANY SIGNIFICANT IDEAS YOU FIND ON THE WEB THAT HAVE HELPED
; YOU DEVELOP YOUR SOLUTION MUST BE CITED AS A COMMENT (THAT
; IS, WHAT THE IDEA IS, PLUS THE URL).

    .cseg
    .org 0

; ==== END OF "DO NOT TOUCH" SECTION ==========
	; THE RESULT **MUST** END UP IN R17
; ==== BEGINNING OF "STUDENT CODE" SECTION ==== 

	; ldi R16, 0b10110110 ; expected output: R17 = 0b01001010
	; ldi R16, 0b01011100 ; expected output: R17 = 0b10100100
	; ldi R16, 0b00000000 ; expected output: R17 = 0b00000000
	; ldi R16, 0b11111111 ; expected output: R17 = 0b00000001
	ldi R16, 0b00110110 ; expected output: R17 = 0b11001010
		.def input = R16
		.def output = R17
	
	ldi R18, 0b11111111			; load 1111 1111 which will be used as a xor mask for later
		.def xorMask = R18

	mov output, input			; copy input to new bit to avoid destruction of original bit

	ShiftUntil1Found:			; this loop finds the rightmost set bit
		SBRC output, 0				; skip next line if bit 2^0 is unset
		RJMP ApplyMask				; if bit 2^0 is set move to next line

		LSL xorMask					; shift the mask to the left
		LSR output					; shift the number to the right

		TST xorMask					; test if entire mask has been shifted away i.e no set bits in input
		BREQ twos_complement_stop   ; end program is there are no set bits

		RJMP ShiftUntil1Found

	ApplyMask:
		LSL xorMask					; shift xor mask once more
		MOV output, input           ; copy original byte back into output byte
		EOR output, xorMask         ; exclusive or operation on output to flip bits 

; ====    END OF "STUDENT CODE" SECTION    ==== 



; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
twos_complement_stop:
    rjmp twos_complement_stop


; ==== END OF "DO NOT TOUCH" SECTION ==========
