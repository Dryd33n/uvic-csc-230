; sixteen-bit-addition.asm
; CSC 230: Spring 2025
;
; Code provided for Assignment #1
;
; Sudhakar Ganti (2023-05-15)

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
; Your task: Two sixteen bit numbers are provided in (R16,
; R17) and (R18,R19). You are to add the two numbers together;
; The final result is stored in R4, R5.
;
; For example, first number is 0x0994, and second number is
; 0xfd35. When these digits are stored in registers, we would have
;   *  0x94 in R16
;   *  0x09 in R17
;   *  0x35 in R18
;   *  0xfd in R19
; with the result of the addition being in R4 and R5
;

; ANY SIGNIFICANT IDEAS YOU FIND ON THE WEB THAT HAVE HELPED
; YOU DEVELOP YOUR SOLUTION MUST BE CITED AS A COMMENT (THAT
; IS, WHAT THE IDEA IS, PLUS THE URL).



    .cseg
    .org 0

	ldi r16, 0x94
	ldi r17, 0x09
    ldi r18, 0x35
    ldi r19, 0xfd

; ==== END OF "DO NOT TOUCH" SECTION ==========

	;Number 1 = r16(94),r17(09) = 0994 = 2452
	;Number 2 = r18(35),r19(fd) = fd35 = 64821
	;Result   = r4(),r5() = 106C9 = 67273
	;Result overflows so r4(C9),r5(06) = 06C9 = 1737 / With carry bit 1737 + 2^16 = 67273

; **** BEGINNING OF "STUDENT CODE" SECTION **** 
	
    add r16, r18 ; Add the lower bytes (R16 and R18)
	;R16 = R16 + R18	//if there is an overflow carry bit will be set 
    mov r4, r16  ; Store the result of the lower byte addition in R4
	;R4 = R16

    
    adc r17, r19 ; Add the upper bytes (R17 and R19) with the carry from the lower byte addition
	;R17 = R17 + R19 + Carry Bit 
    mov r5, r17  ; Store the result of the upper byte addition in R5
	;R5 = R17

; **** END OF "STUDENT CODE" SECTION ********** 
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
sixteen_bit_addition_end:
	rjmp sixteen_bit_addition_end



; ==== END OF "DO NOT TOUCH" SECTION ==========
