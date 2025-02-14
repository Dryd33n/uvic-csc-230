; a2-signalling.asm
; CSC 230: Spring 2025
;
; Student name:
; Student ID:
; Date of completed work:
;
; *******************************
; Code provided for Assignment #2
;
; Author: Mike Zastre (2022-Oct-15)
; Modified: Sudhakar Ganti (2025-Jan-31)
 
; This skeleton of an assembly-language program is provided to help you
; begin with the programming tasks for A#2. As with A#1, there are "DO
; NOT TOUCH" sections. You are *not* to modify the lines within these
; sections. The only exceptions are for specific changes changes
; announced on Brightspace or in written permission from the course
; instructor. *** Unapproved changes could result in incorrect code
; execution during assignment evaluation, along with an assignment grade
; of zero. ****

.include "m2560def.inc"
.cseg
.org 0

; ***************************************************
; **** BEGINNING OF FIRST "STUDENT CODE" SECTION ****
; ***************************************************

	 ; --- SET LED's TO OUTPUT ---
    ldi r17, 0b11111111
    sts DDRL, r17  ; Set all bits of DDRL (Data Direction Register L) to output
    out DDRB, r17  ; Set all bits of DDRB (Data Direction Register B) to output
    clr r17

    ; --- INITIALIZE STACK POINTER ---
    ldi r16, low(RAMEND)
    out SPL, r16
    ldi r16, high(RAMEND)
    out SPH, r16



; ***************************************************
; **** END OF FIRST "STUDENT CODE" SECTION **********
; ***************************************************

; ---------------------------------------------------
; ---- TESTING SECTIONS OF THE CODE -----------------
; ---- TO BE USED AS FUNCTIONS ARE COMPLETED. -------
; ---------------------------------------------------
; ---- YOU CAN SELECT WHICH TEST IS INVOKED ---------
; ---- BY MODIFY THE rjmp INSTRUCTION BELOW. --------
; -----------------------------------------------------

	rjmp test_part_d
	; Test code


test_part_a:
	ldi r16, 0b00100001
	rcall configure_leds
	rcall delay_long

	clr r16
	rcall configure_leds
	rcall delay_long

	ldi r16, 0b00111000
	rcall configure_leds
	rcall delay_short

	clr r16
	rcall configure_leds
	rcall delay_long

	ldi r16, 0b00100001
	rcall configure_leds
	rcall delay_long

	clr r16
	rcall configure_leds

	rjmp end


test_part_b:
	ldi r17, 0b00101010
	rcall slow_leds
	ldi r17, 0b00010101
	rcall slow_leds
	ldi r17, 0b00101010
	rcall slow_leds
	ldi r17, 0b00010101
	rcall slow_leds

	rcall delay_long
	rcall delay_long

	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds

	rjmp end

test_part_c:
	ldi r16, 0b11111000
	push r16
	rcall leds_with_speed
	pop r16

	ldi r16, 0b11011100
	push r16
	rcall leds_with_speed
	pop r16

	ldi r20, 0b00100000
test_part_c_loop:
	push r20
	rcall leds_with_speed
	pop r20
	lsr r20
	brne test_part_c_loop

	rjmp end


test_part_d:
	ldi r21, 'V'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	ldi r21, 'A'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	ldi r21, 'B'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long


	ldi r21, 'C'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	rjmp end


test_part_e:
	ldi r25, HIGH(WORD05 << 1)
	ldi r24, LOW(WORD05 << 1)
	rcall display_message_signal
	rjmp end

end:
    rjmp end






; ****************************************************
; **** BEGINNING OF SECOND "STUDENT CODE" SECTION ****
; ****************************************************










;========================================================================================;
;                         ??????????????????????????????????????                         ;
;                         ?       BEGIN CONFIGURE LED's        ?                         ;                                                                            
;                         ??????????????????????????????????????                         ;
;========================================================================================;
;                                                                                ;
;    DESCRIPTION:                                                                ;
;            - Configures and sets the output of LED's connected via PORTL &     ;
;              PORTB by interpreting R16 binary's representation to determine    ;
;              which LED's to turn on/off.                                       ;
;                                                                                ;
;    PARAMETERS:                                                                 ;
;            - R16   (Where the 6 rightmost bits represents led's to turn on)    ;
;                                                                                ;        
;    OUTPUT:                                                                     ;
;            - PORTB (Used for LED's [ ][ ][*][*][*][*])                         ;    
;            - PORTL (Used for LED's [*][*][ ][ ][ ][ ])                         ;
;                                                                                ;
;    REGISTERS:                                                                  ;
;            - R17   (Scratch Register to build outputs for PORTB & PORTL)       ;
;                                                                                ;
;================================================================================;
configure_leds:
    ; --- INITIALIZATION ---
    clr r17                        ; Precautionary measure before performing operations

    ; --- PORTL MAPPING ---
    sbrc r16, 5                    ; Test for LED 6 off, if off skip following instruction
        ori r17, 0b10000000        ; Add bit configuration for [ ][ ][ ][ ][ ][*] to mask

    sbrc r16, 4                    ; Test for LED 5 off, if off skip following instruction
        ori r17, 0b00100000        ; Add bit configuration for [ ][ ][ ][ ][*][ ] to mask

    sbrc r16, 3                    ; Test for LED 4 off, if off skip following instruction
        ori r17, 0b00001000        ; Add bit configuration for [ ][ ][ ][*][ ][ ] to mask

    sbrc r16, 2                    ; Test for LED 3 off, if off skip following instruction
        ori r17, 0b00000010        ; Add bit configuration for [ ][ ][*][ ][ ][ ] to mask

    ; --- PORTL OUTPUT ---
    sts PORTL, r17
    clr r17
    
    ; --- PORTB MAPPING ---
    sbrc r16, 1                    ; Test for LED 2 off, if off skip following instruction
        ori r17, 0b00001000        ; Add bit configuration for [ ][*][ ][ ][ ][ ] to mask

    sbrc r16, 0                    ; Test for LED 1 off, if off skip following instruction
        ori r17, 0b00000010        ; Add bit configuration for [*][ ][ ][ ][*][ ] to mask

    ; --- PORTL OUTPUT --- 
    out PORTB, r17
    
    ; --- CLEANUP --- 
    clr r17
    clr r16

    ret
;========================================================================================;
;                         ??????????????????????????????????????                         ;
;                         ?        END CONFIGURE LED's         ?                         ;                                                                                    
;                         ??????????????????????????????????????                         ;
;========================================================================================;










;========================================================================================;
;                         ??????????????????????????????????????                         ;
;                         ?         BEGIN SLOW LED's           ?                         ;                                                                            
;                         ??????????????????????????????????????                         ;
;========================================================================================;
;                                                                                ;
;    DESCRIPTION:                                                                ;
;            - Calls configure LED's twice. Initially turns LED's on based on    ;
;              contents of R17, then waits a delay_long and turns of the LED's   ;
;                                                                                ;
;    PARAMETERS:                                                                 ;
;            - R17   (Where the 6 rightmost bits represents LED's to turn on)    ;
;                                                                                ;        
;    OUTPUT:                                                                     ;
;            - PORTB (Used for LED's [ ][ ][*][*][*][*])                         ;    
;            - PORTL (Used for LED's [*][*][ ][ ][ ][ ])                         ;
;                                                                                ;
;    REGISTERS:                                                                  ;
;            - R16    (Used as a parameter when calling configure LED's)         ;
;                                                                                ;
;================================================================================
slow_leds:
    ; --- INITIALIZATION ---
    mov r16, r17                ; Prepare parameter for configure LED's

    ; --- TURN ON LED'S ---
    rcall configure_leds        ; Illuminate LED's

    ; --- DELAY ---
    ;rcall delay_long            ; Wait approx 1s

    ; --- DISABLE LED'S ---
    clr r16                     ; Prepare parameter for configure LED;s
    rcall configure_leds        ; Disable all LED'S

    ret
;========================================================================================;
;                         ??????????????????????????????????????                         ;
;                         ?          END SLOW LED's            ?                         ;                                                                            
;                         ??????????????????????????????????????                         ;
;========================================================================================;










;========================================================================================;
;                         ??????????????????????????????????????                         ;
;                         ?         BEGIN FAST LED's           ?                         ;                                                                            
;                         ??????????????????????????????????????                         ;
;========================================================================================;
;                                                                                ;
;    DESCRIPTION:                                                                ;
;            - Calls configure LED's twice. Initially turns LED's on based on    ;
;              contents of R17, then waits a delay_short and turns of the LED's  ;
;                                                                                ;
;    PARAMETERS:                                                                 ;
;            - R17   (Where the 6 rightmost bits represents LED's to turn on)    ;
;                                                                                ;        
;    OUTPUT:                                                                     ;
;            - PORTB (Used for LED's [ ][ ][*][*][*][*])                         ;    
;            - PORTL (Used for LED's [*][*][ ][ ][ ][ ])                         ;
;                                                                                ;
;    REGISTERS:                                                                  ;
;            - R16    (Used as a parameter when calling configure LED's)         ;
;                                                                                ;
;================================================================================;
fast_leds:
    ; --- INITIALIZATION ---
    mov r16, r17                ; Prepare parameter for configure LED's

    ; --- TURN ON LED'S ---
    rcall configure_leds        ; Illuminate LED's

    ; --- DELAY ---
    rcall delay_short            ; Wait approx 0.25s

    ; --- DISABLE LED'S ---
    clr r16                     ; Prepare parameter for configure LED's
    rcall configure_leds        ; Disable all LED'S

    ret
;========================================================================================;
;                         ??????????????????????????????????????                         ;
;                         ?          END FAST LED's            ?                         ;                                                                            
;                         ??????????????????????????????????????                         ;
;========================================================================================;










;========================================================================================;
;                         ??????????????????????????????????????                         ;
;                         ?       BEGIN LED'S WITH SPEED       ?                         ;                                                                            
;                         ??????????????????????????????????????                         ;
;========================================================================================;
;                                                                                ;
;    DESCRIPTION:                                                                ;
;            - Controls the 6 LED's at different speed based on parameter passed ;
;              to the stack.                                                     ;
;    PARAMETERS:                                                                 ;
;            - 1 Byte Pushed to Stack (Which LED's and what speed information)   ;
;                                                                                ;        
;    OUTPUT:                                                                     ;
;            - PORTB (Used for LED's [ ][ ][*][*][*][*])                         ;    
;            - PORTL (Used for LED's [*][*][ ][ ][ ][ ])                         ;
;                                                                                ;
;    REGISTERS:                                                                  ;
;            - R17    (Used as a parameter when calling fast&slow_led)           ;
;            - R16    (Used to store parameter passed to stack aswell as mask)   ;
;                                                                                ;
;================================================================================;
leds_with_speed:
	; --- INITIALIZATION ---
	in YH, SPH                 ; Store High Stack Pointer from SRAM Stack Region to Y-High
	in YL, SPL                 ; Store Low Stack Pointer from SRAM Stack Region to Y-Low
	ldd R16, Y+4               ; Read function parameter from stack and store in R16
	mov R17, R16               ; Save stack parameter into R17 for use as a parameter in slow_leds & fast_leds

	; --- BRANCHING ---
	andi R16, 0b11000000       ; Perform and and mask with the function parameter, result will be 0 if slow configuration is used
	breq fast                  ; If result of mask was 0, slow configuration is being used, therefore branch to "slow"

	; --- SLOW LED BRANCH ---
	    CALL slow_leds        ; Call slow_leds routine
	    ret                    ; Exit out of this routine
	; --- FAST LED BRANCH ---
	fast:
	    CALL fast_leds		   ; Call fast_leds routine
	    ret                    ; Exit out of this routine
;========================================================================================;
;                         ??????????????????????????????????????                         ;
;                         ?       END LED'S WITH SPEED         ?                         ;                                                                            
;                         ??????????????????????????????????????                         ;
;========================================================================================;


; Note -- this function will only ever be tested
; with upper-case letters, but it is a good idea
; to anticipate some errors when programming (i.e. by
; accidentally putting in lower-case letters). Therefore
; the loop does explicitly check if the hyphen/dash occurs,
; in which case it terminates with a code not found
; for any legal letter.


;========================================================================================;
;                         ??????????????????????????????????????                         ;
;                         ?        BEGIN ENCODE LETTER         ?                         ;                                                                            
;                         ??????????????????????????????????????                         ;
;========================================================================================;
;                                                                                ;
;    DESCRIPTION:                                                                ;
;            - Controls the 6 LED's at different speed based on parameter passed ;
;              to the stack.                                                     ;
;    PARAMETERS:                                                                 ;
;            - 1 Byte Pushed to Stack (Which LED's and what speed information)   ;
;                                                                                ;        
;    OUTPUT:                                                                     ;
;            - R25   (A byte that is valid to execute with LED's with speed)     ;
;                                                                                ;
;    REGISTERS:                                                                  ;
;            - Y     (Stack Pointer to retrieve parameter)                       ;
;            - R16   (Register to store parameter pointed to by Y)               ;
;            - Z     (Pointer which traverses through .db table)                 ;
;            - R17   (Used to hold information loaded from table)                ;
;            - R18   (Used as a counter while traversin pattern)                 ;
;                                                                                ;
;================================================================================;
encode_letter:
    ; --- INITIALIZATION ---
; <- Store Stack Pointer in Y then store Parameter from stack pointer in R16 ->
	in YH, SPH                           ; Store high stack pointer in y-high
	in YL, SPL                           ; Store low stack pointer in y-low
	ldd R16, Y+4                         ; Store value / character pushed to stack in R16
; <- Store Pointer to start of Table in Z ->
	ldi ZH, high(PATTERNS<<1)            ; Stores the High Byte of the pointer to the start of the table in z-high
	ldi ZL, low(PATTERNS<<1)             ; Stores the Low Byte of the pointer to the start of the table in z-low
; <- Ensure output register is clear ->
	clr R25

	; --- TABLE LOOKUP LOOP ---
	;	This loop traverses the pattern table one row at a time, comparing each
	;   letter to the parameter stored in R16. It traverses the table by incrementing
	;   the pointer Z which starts out pointing to the first piece of data in the table,
	;   by incrementing the pointer by 8, which is the length of one row, we traverse down
	;   to the next letter stored at the start of the row, once the letter pointed to by z
	;   matches the parameter we branch out of the loop. 
	table_row_traversal:
	    lpm R17, Z                       ; Z is a pointer to start of table, this loads the first item in table which is the letter
	    cp R16, R17                      ; Compare letter from table (R17) with letter from parameter (R16)
	    breq proccess_pattern            ; If the letter from the table and the letter from the parameter match, proceed to next step
		adiw Z,8                         ; Increase table pointer by 8 bytes since table row is [1 byte (letter) + 6 bytes (pattern) + 1 byte (delay code)] = 8 bytes
		rjmp table_row_traversal         ; Go back to top of loop
	

	; --- PROCCESS PATTERN LOOP ---
	;   This loop increments are table pointer Z each iteration traversing through the pattern in the table
	;   while each iteration checking if the character in the pattern pointed to by Z is an 'o' or not. If it 
	;   is we set the rmb of our output to 1. We then LSL our output to the left each iteration, thus if we never
	;   encounter a 'o' it will just shift left leaving us blank space, if we ecounter 'o' everytime it will shift
	;   left making the 6 rmb's set. Once we have traversed the entire pattern branch out of the loop
	; <- Loop Initialization ->
	proccess_pattern:
		ldi R18, 0x06
			.def counter = R18
    pattern_traversal:
		adiw Z,1                         ; Increase table pointer by 1, we do this at the start of the loop since currently it is pointing to the first column containing the letter
		lpm R17, Z						 ; Load the letter from the pattern pointed to by Z into R17
		cpi R17, 0x6f                    ; Checks if the current letter of the pattern is 'o'
		brne not_set                     ; Branch if the letter of the pattern is not 'o' indicating the LED should not be set
			ori R25, 0b00000001          ; Since R25 is clr'd and we lsl it later in the loop this will always set the first bit
		
		not_set:                         ; If the current letter in patern pointed to by Z is not 'o' we do not set any bits
		dec counter                      ; Decrease counter by 1
		breq proccess_delay              ; If the counter has reached 0, meaning we have traversed the entire pattern then branch out of the loop
		lsl R25                          ; Shift our current output to the left creating blank space on the left
		
		rjmp pattern_traversal           ; Continuing traversing the pattern

	proccess_delay:
		adiw Z,1                         ; Increment our table pointer Z by 1 so that it is now pointing to the delay code
		lpm R17, Z                       ; Load the delay code pointed to by Z into R17
		dec R17                          ; Decrement R17, if it is 1 it will now be 0 and if it is 2 it will now be 1 which lets us test the bit
		sbrs R17, 0                      ; We do not set the 2 lmb's if R17's rmb is set, i.e the delay code is 2
		    ori R25, 0b11000000          ; If R17's rmb is clear, it means delay code was 1 so we set the 2 lmb's
		
ret
;========================================================================================;
;                         ??????????????????????????????????????                         ;
;                         ?         END ENCODE LETTER          ?                         ;                                                                            
;                         ??????????????????????????????????????                         ;
;========================================================================================;










;========================================================================================;
;                         ??????????????????????????????????????                         ;
;                         ?       BEGIN DISPLAY MESSAGE        ?                         ;                                                                            
;                         ??????????????????????????????????????                         ;
;========================================================================================;
;                                                                                ;
;    DESCRIPTION:                                                                ;
;            - Displays a word pointed to by R24:R25 using signaling on LED's    ;
;    PARAMETERS:                                                                 ;
;            - R25 High byte of pointer pointing to start of word                ;
;            - R24 Low byte of pointer pointing to start of word                 ;
;                                                                                ;        
;    OUTPUT:                                                                     ;
;            - PORTB (Used for LED's [ ][ ][*][*][*][*])                         ;    
;            - PORTL (Used for LED's [*][*][ ][ ][ ][ ])                         ;
;                                                                                ;
;    REGISTERS:                                                                  ;
;            - Z     (A pointer used to traverse through the word)               ;
;            - R18   (Used to store letters accessed through address in Z)       ;
;                                                                                ;
;================================================================================;
display_message_signal:
    ; --- INITIALIZATION ---
	mov ZL, r24 ; store the low byte of the address in the callee to ZL
	mov ZH, r25 ; stroe the high byte of the address in the callee to ZH

	display_word_loop:
 	    lpm R18, Z+                ; Increase the pointer traversing the word
		tst R18                    ; Check if the pointer pointing to a letter in the word is null indiciated we have reached the end of the word
		breq word_finished         ; Branch if the pointer is pointing to a null character indiciated the word is finished

		; --- ENCODE LETTER ---
		push R18                   ; Add R18 to the stack as a parameter for encode letter
		CALL encode_letter        ; Encode the letter  
		pop R18                    ; Remove R18 from the stack to avoid polluting the stack
		; --- DISPLAY LETTER ---
		push R25                   ; Encode letter stores the result in R25 so push into stack as a parameter for display letter
		CALL leds_with_speed      ; Display the letter
		pop R25                    ; Remove from stack to avoid polluting the stack

		RJMP display_word_loop     ; Go back to the start of the loop

    word_finished:
	    ret
;========================================================================================;
;                         ??????????????????????????????????????                         ;
;                         ?        END DISPLAY MESSAGE         ?                         ;                                                                            
;                         ??????????????????????????????????????                         ;
;========================================================================================;










; ****************************************************
; **** END OF SECOND "STUDENT CODE" SECTION **********
; ****************************************************




; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================

; about one second
delay_long:
	push r16

	ldi r16, 14
delay_long_loop:
	rcall delay
	dec r16
	brne delay_long_loop

	pop r16
	ret


; about 0.25 of a second
delay_short:
	push r16

	ldi r16, 4
delay_short_loop:
	rcall delay
	dec r16
	brne delay_short_loop

	pop r16
	ret

; When wanting about a 1/5th of a second delay, all other
; code must call this function
;
delay:
	rcall delay_busywait
	ret


; This function is ONLY called from "delay", and
; never directly from other code. Really this is
; nothing other than a specially-tuned triply-nested
; loop. It provides the delay it does by virtue of
; running on a mega2560 processor.
;
delay_busywait:
	push r16
	push r17
	push r18

	ldi r16, 0x08
delay_busywait_loop1:
	dec r16
	breq delay_busywait_exit

	ldi r17, 0xff
delay_busywait_loop2:
	dec r17
	breq delay_busywait_loop1

	ldi r18, 0xff
delay_busywait_loop3:
	dec r18
	breq delay_busywait_loop2
	rjmp delay_busywait_loop3

delay_busywait_exit:
	pop r18
	pop r17
	pop r16
	ret


; Some tables
;.cseg
;.org 0x800

PATTERNS:
	; LED pattern shown from left to right: "." means off, "o" means
    ; on, 1 means long/slow, while 2 means short/fast.
	.db "A", "..oo..", 1
	.db "B", ".o..o.", 2
	.db "C", "o.o...", 1
	.db "D", ".....o", 1
	.db "E", "oooooo", 1
	.db "F", ".oooo.", 2
	.db "G", "oo..oo", 2
	.db "H", "..oo..", 2
	.db "I", ".o..o.", 1
	.db "J", ".....o", 2
	.db "K", "....oo", 2
	.db "L", "o.o.o.", 1
	.db "M", "oooooo", 2
	.db "N", "oo....", 1
	.db "O", ".oooo.", 1
	.db "P", "o.oo.o", 1
	.db "Q", "o.oo.o", 2
	.db "R", "oo..oo", 1
	.db "S", "....oo", 1
	.db "T", "..oo..", 2
	.db "U", "o.....", 1
	.db "V", "o.o.o.", 2
	.db "W", "o.o...", 2
	.db "W", "oo....", 2
	.db "Y", "..oo..", 2
	.db "Z", "o.....", 2
	.db "-", "o...oo", 1   ; Just in case!

WORD00: .db "CSC230", 0, 0
WORD01: .db "ALL", 0
WORD02: .db "ROADS", 0, 0, 0
WORD03: .db "LEAD", 0, 0, 0, 0
WORD04: .db "TO", 0, 0
WORD05: .db "UVIC", 0, 0, 0, 0

; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================

