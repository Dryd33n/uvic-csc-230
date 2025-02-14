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

	; initializion code will need to appear in this
    ; section


	;SET LED's TO OUTPUT
	ldi r17, 0b11111111
	sts DDRL, r17  ; Set all bits of DDRL (Data Direction Register L) to output
	out DDRB, r17  ; Set all bits of DDRB (Data Direction Register B) to output
	clr r17

	



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

	rjmp test_part_a
	; Test code


test_part_a:


	ldi r16, 0b00111111
	rcall configure_leds
	rcall delay_long

	clr r16
	rcall configure_leds
	rcall delay_short

	ldi r16, 0b00100000
	rcall configure_leds
	rcall delay_short
	ldi r16, 0b00010000
	rcall configure_leds
	rcall delay_short
	ldi r16, 0b00001000
	rcall configure_leds
	rcall delay_short
	ldi r16, 0b00000100
	rcall configure_leds
	rcall delay_short
	ldi r16, 0b00000010
	rcall configure_leds
	rcall delay_short
	ldi r16, 0b00000001
	rcall configure_leds
	rcall delay_short
	ldi r16, 0b00000010
	rcall configure_leds
	rcall delay_short
	ldi r16, 0b00000100
	rcall configure_leds
	rcall delay_short
	ldi r16, 0b00001000
	rcall configure_leds
	rcall delay_short
	ldi r16, 0b00010000
	rcall configure_leds
	rcall delay_short
	ldi r16, 0b00100000
	rcall configure_leds
	rcall delay_short

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



configure_leds:
	clr r17


	; check each bit with sbrc in r16, i.e bits 5,4,3,2,1,0

	;build r17 to have proper bits set to send to io for PORTB
	sbrc r16, 5
	ori r17, 0b10000000
	sbrc r16, 4
	ori r17, 0b00100000
	sbrc r16, 3
	ori r17, 0b00001000
	sbrc r16, 2
	ori r17, 0b00000010

	sts PORTL, r17
	clr r17
	
	;build r16 to have proper bits set to send to io for PORTL
	sbrc r16, 1
	ori r17, 0b00001000
	sbrc r16, 0
	ori r17, 0b00000010

	out PORTB, r17 
	clr r17
	clr r16

	ret

slow_leds:
	ret


fast_leds:
	ret


leds_with_speed:
	ret


; Note -- this function will only ever be tested
; with upper-case letters, but it is a good idea
; to anticipate some errors when programming (i.e. by
; accidentally putting in lower-case letters). Therefore
; the loop does explicitly check if the hyphen/dash occurs,
; in which case it terminates with a code not found
; for any legal letter.

encode_letter:
	ret


display_message_signal:
	ret


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

