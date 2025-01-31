	; reset-rightmost.asm
	; CSC 230: Spring 2025
	;
	; Code provided for Assignment #1
	; Author: Mike Zastre
	; 

	; This skeleton of an assembly-language program is provided to help you
	; begin with the programming task for A#1, part (b). In this and other
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
	; and to reset the rightmost contiguous sequence of set
	; by storing this new value in R1. For example, given
	; the bit sequence 0b01011100, resetting the right-most
	; contigous sequence of set bits will produce 0b01000000.
	; As another example, given the bit sequence 0b10110110,
	; the result will be 0b10110000.
	;
	; Your solution must work, of course, for bit sequences other
	; than those provided in the example. (How does your
	; algorithm handle a value with no set bits? with all set bits?)

	; ANY SIGNIFICANT IDEAS YOU FIND ON THE WEB THAT HAVE HELPED
	; YOU DEVELOP YOUR SOLUTION MUST BE CITED AS A COMMENT (THAT
	; IS, WHAT THE IDEA IS, PLUS THE URL).

		.cseg
		.org 0

	; ==== END OF "DO NOT TOUCH" SECTION ==========
		; THE RESULT **MUST** END UP IN R1
	; **** BEGINNING OF "STUDENT CODE" SECTION **** 

	
		ldi R16, 0b01011100
		; ldi R16, 0b10110110
		; ldi R16, 0b00000000
		; ldi R16, 0b10000000
		; ldi R16, 0b00001011
		; ldi R16, 0b00000101
		; ldi R16, 0b00001010
		mov R1, R16
			.def result = R1

		ldi R20, 0x00; Initialize Counter
			.def counter = R20

		FindFirst1:					; this loop finds the rightmost bit then once it is found goes to the next FindFollowing0 loop
			SBRC result, 0				; skip following line if rightmost bit in R16 is 0
			RJMP FindFollowing0			; go to next loop if rightmost bit in R16 is 1, ie. first rightmost set bit found
	
			INC counter					; increase counter reg
			LSR result					; shift R16 rightwards filling in with 0's

			CPI  counter, 0x08			; compare counter to see if it is equal to 8, i.e whole byte has been scanned
			BREQ reset_rightmost_stop	; if entire bit has been scrolled without finding 1 end program

			RJMP FindFirst1				;go back to start of loop after shiftin R1 and testing whole byte hasn't been scrolled

		FindFollowing0:             ; this loop finds the following 0 after the rightmost 1 has been found
			LSR result					; shift R1 right filling in with 0's
			INC counter					; increase counter by 1

			SBRC result, 0				; skips next line is the rightmost bit is 0
			RJMP FindFollowing0			; go back to start of loop after shifting r1 again and rightmost bit is not 0 

		ReShiftToOriginal:			; this loop shifts r01 back to its original position after shifting the rightmost bits away
			LSL result					; shifts r1 to the left by 1
			DEC counter					; decrements the counter
			BRNE ReShiftToOriginal		; once the counter has been decremented to 0 finish the program
		 



	; **** END OF "STUDENT CODE" SECTION ********** 
	; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
	reset_rightmost_stop:
		rjmp reset_rightmost_stop


	; ==== END OF "DO NOT TOUCH" SECTION ==========
