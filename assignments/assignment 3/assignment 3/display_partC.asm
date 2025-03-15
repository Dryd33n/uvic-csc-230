.org 0
	rjmp start
.org 0x002A        ; Timer1 Compare A interrupt vector
    jmp timer1_isr

#define LCD_LIBONLY
.include "lcd.asm"

.cseg
;                         ??????????????????????????????????????                         ;
;                         ?           INITIALIZATION           ?                         ;                                                                            
;                         ??????????????????????????????????????                         ;
start:
    ; <-- TIMER DEFINITIONS FOR 1S DELAY -->
    .equ CLOCK     = 16000000
    .equ PRESCALER = 1024
    .equ DELAY     = 1
    .equ TOP       = int(0.5+((CLOCK/PRESCALER)*(DELAY)))

    ; <-- INITIALIZE STACK POINTER -->
    ldi r16, low(RAMEND)   ; Get RAMEND Low
    out SPL, r16           ; Initialize Stack Pointer Low
    ldi r16, high(RAMEND)  ; Get RAMEND High
    out SPH, r16           ; Initialize Stack Pointer High

    ; <-- INITIALIZE TIMER -->
    rcall timer_init
	rcall timer1_init
	cli

    call lcd_init			; call lcd_init to Initialize the LCD
	call lcd_clr

	clr r20
	clr r21
	ldi r22, 0b00000011


;                         ??????????????????????????????????????                         ;
;                         ?        MAIN EXECUTION LOOP         ?                         ;                                                                            
;                         ??????????????????????????????????????                         ;
    ; <-- ENTER MAIN LOOP -->
    loop:
	; -- DISPLAY BOTH LINES --
		cli
		call lcd_clr
		clr r22
		ori r22, 0b00000011
		rcall display_line1_rotated
		rcall display_line2_rotated
		sei
        	rcall delay_1s

	; -- DISPLAY FIRST LINE --
		cli
        	call lcd_clr
        	clr r22
		ori r22, 0b00000001
		rcall display_line1_rotated
		sei
        	rcall delay_1s

	; -- DISPLAY SECOND LINE --
		cli	
        	call lcd_clr
        	clr r22
		ori r22, 0b00000010
		rcall display_line2_rotated
		sei
        	rcall delay_1s

        rjmp loop
;                         ??????????????????????????????????????                         ;
;                         ?      END MAIN EXECUTION LOOP       ?                         ;                                                                            
;                         ??????????????????????????????????????                         ;










;========================================================================================;
;                         ??????????????????????????????????????                         ;
;                         ?         INTIAILIZE TIMER1          ?                         ;                                                                            
;                         ??????????????????????????????????????                         ;
;========================================================================================;
;                                                                                ;
;    DESCRIPTION:                                                                ;
;            - Sets a top value and configures the display mode for timer1       ;
;    PARAMETERS:                                                                 ;
;            - TOP a definition containing the top value for the timer           ;
;                                                                                ;        
;    OUTPUT:                                                                     ;
;            - OCR1AH / OCR1AL Holds the top value for timer1                    ;    
;            - TCCR1A Holds the configuration of PWM mode for timer              ;
;                                                                                ;
;    REGISTERS:                                                                  ;
;            - r16 Used as temporary variables to store timer configuartion      ;
;                                                                                ;
;================================================================================;		
	timer1_init:
		push r16 ; Protect r16


		; <-- CTC MODE -->
		ldi r16, 0x00				    ; Create value for CTC MODE
		sts TCCR1A, r16				    ; Set value for CTC mode
		
		; <-- PRESCALER -->
		ldi r16, (1<<WGM12) | (1<<CS12) | (1<<CS10) ; Create value to set prescaler to 1024 and CTC mode (WGM12 = 1)
		sts TCCR1B, r16                             ; Set value for prescaler and CTC mode

		; <-- TOP VALUE -->
		ldi r16, high(5000)			    ; Get high byte of top value
		sts OCR1AH, r16                             ; Set high byte of top value
		ldi r16, low(5000)                          ; Get low byte of top value
		sts OCR1AL, r16				    ; Set low byte of top value

		; < -- ENABLE INTERRUPT --> 
		ldi r16, (1<<OCIE1A)		            ; Get value to enable timer        
		sts TIMSK1, r16				    ; Set value to enable timer


		pop r16 ; Restore r16
	ret                    
;========================================================================================;
;                         ??????????????????????????????????????                         ;
;                         ?       END INTIAILIZE TIMER1        ?                         ;                                                                            
;                         ??????????????????????????????????????                         ;
;========================================================================================;











;========================================================================================;
;                         ??????????????????????????????????????                         ;
;                         ?            TIMER 1 ISR             ?                         ;                                                                            
;                         ??????????????????????????????????????                         ;
;========================================================================================;
;                                                                                ;
;    DESCRIPTION:                                                                ;
;            - Scrolls and displays lines depending on configuration register    ;
;    PARAMETERS:                                                                 ;
;            - R20, current offset for line 1                                    ;
;	     - R21, current offset for line 2                                    ;
;            - R22, configuration for which lines to scroll and display          ;
;                                                                                ;        
;    OUTPUT:                                                                     ;
;            - R20, incremeneted if configured to scroll line 1                  ;
;            - R21, incremeneted if configured to scroll line 2                  ;
;            - LCD updates LCD                                                   ;
;                                                                                ;
;================================================================================;
timer1_isr:
	cli	 ; Disable global interrupts during ISR
	call scroll_lines_right
	sei  ; Enable global interrupts on exit of ISR
	reti ; Return from ISR
;========================================================================================;
;                         ??????????????????????????????????????                         ;
;                         ?          END TIMER 1 ISR           ?                         ;                                                                            
;                         ??????????????????????????????????????                         ;
;========================================================================================;
scroll_lines_left:
cli
			sbrs r22, 0	            ; Determine if configuration register is set to display first line
		rjmp skip_line_1    ; Do not skip if configuration says display line 1

	inc r20				; Increment r20
	line_1_offset_modulo:		; Preforms a modulo operation on r20 with divisor msg1_length
		cpi r20, msg1_length        ; Checks if the current offset for line 1 is bigger than the length
		brlo display_first_line	    ; If it is not exit from the loop
		subi r20, msg1_length       ; If it is larger then subtract msg1_length and check again to see if it is bigger
		rjmp line_1_offset_modulo   ; go back to start of loop

	display_first_line:
		rcall display_line1_rotated ; Display the rotated line 1 with offset r20

	skip_line_1:

	sbrs r22, 1         ; Determine if configuration register is set to display seceond line
	rjmp skip_line_2    ; Do not skip if configuration says display line 2

	inc r21                         ; Increment r21
	line_2_offset_modulo:           ; Preforms a modulo operation on r21 with divisor msg2_length
		cpi r21, msg2_length        ; Checks if the current offset for line 2 is bigger than the length of the message
		brlo display_second_line    ; If the offset is smaller exit the loop
		subi r21, msg2_length       ; If the offset is bigger subtract msg2_length and then check again to see if it is bigger
		rjmp line_2_offset_modulo   ; Go back to start of loop
	
	display_second_line:
		rcall display_line2_rotated ; Display rotated line 2 with offset r21

	skip_line_2:
	sei
	ret




scroll_lines_right:
cli
	sbrs r22, 0	            ; Determine if configuration register is set to display first line
	rjmp skip_line_1_r    ; Do not skip if configuration says display line 1

	rcall display_line1_rotated

	dec r20				; Increment r20
	tst r20
	brpl skip_line_1_r	    ; If it is not exit from the loop
	ldi r20, msg1_length
	dec r20


	skip_line_1_r:

	sbrs r22, 1         ; Determine if configuration register is set to display seceond line
	rjmp skip_line_2_r    ; Do not skip if configuration says display line 2

	rcall display_line2_rotated ; Display rotated line 2 with offset r21

	dec r21                         ; Increment r21

	tst r21
	brpl skip_line_2_r    ; If the offset is smaller exit the loop
	ldi r21, msg2_length
	dec r21
		

	skip_line_2_r:
	sei
    ret








;========================================================================================;
;                         ??????????????????????????????????????                         ;
;                         ?          INTIAILIZE TIMER          ?                         ;                                                                            
;                         ??????????????????????????????????????                         ;
;========================================================================================;
;                                                                                ;
;    DESCRIPTION:                                                                ;
;            - Sets a top value and configures the display mode for timer3       ;
;    PARAMETERS:                                                                 ;
;            - TOP a definition containing the top value for the timer           ;
;                                                                                ;        
;    OUTPUT:                                                                     ;
;            - OCR3AH / OCR3AL Holds the top value for timer3                    ;    
;            - TCCR3A Holds the configuration of PWM mode for timer              ;
;                                                                                ;
;    REGISTERS:                                                                  ;
;            - r16,r17 Used as temporary variables to store timer configuartion  ;
;                                                                                ;
;================================================================================;
    timer_init:
		; <-- PROTECT REGISTERS -->
		push r16
		push r17

        ; <-- SET TOP VALUE -->
        ldi r16,     high(TOP)        ; Load High value of TOP
        ldi r17,     low(TOP)         ; Load Low value of TOP
        sts OCR3AH,  r16              ; Set High value of TOP
        sts OCR3AL,  r17              ; Set Low value of TOP
        
        ; <-- DISABLE PWM MODE -->
        ldi r16, 0                    ; Load 0 as configuration for PWM 
        sts TCCR3A, temp              ; Set 0 as configuration for PWM

		; <-- RESTORE REGISTERS -->
		pop r17
		pop r16
    ret   
;========================================================================================;
;                         ??????????????????????????????????????                         ;
;                         ?        END INTIAILIZE TIMER        ?                         ;                                                                            
;                         ??????????????????????????????????????                         ;
;========================================================================================;










;========================================================================================;
;                         ??????????????????????????????????????                         ;
;                         ?            DELAY FOR 1S            ?                         ;                                                                            
;                         ??????????????????????????????????????                         ;
;========================================================================================;
;                                                                                ;
;    DESCRIPTION:                                                                ;
;            - Halt program execution for 1 second                               ;
;    PARAMETERS:                                                                 ;
;            - Assumes OCR3A is set with proper top value for delay              ;
;            - Assumes TCCR3A is set with proper configuration for CTC mode      ;
;                                                                                ;        
;    OUTPUT:                                                                     ;
;            - TCCR3B Holds the configuration for CTC mode and prescaler         ;    
;            - TIFR3  Reset after timer is done                                  ;
;                                                                                ;
;    REGISTERS:                                                                  ;
;            - r16 Used as temporary variable to store timer configuartion       ;
;                                                                                ;
;================================================================================;
    delay_1s:
		push r16
        ; <-- SET CTC MODE AND PRESCALER -->
        ldi r16, (1 << WGM32) | (1 << CS32) | (1 << CS30)   ; CTC mode and prescaler 1024
        sts TCCR3B, r16                                     ; Set CTC and Prescaler

        ; [ BEGIN POLLING TIMER ]
        wait_for_timer:
            sbic TIFR3, OCF3A       ; Skip if OCF3A (Output Compare Flag) is not set
            rjmp timer_done         ; Jump if OCF3A is set

            rjmp wait_for_timer     ; Keep waiting for the timer to overflow

        timer_done:
            ; Clear the OCF3A flag by writing a 1 to it
            sbi TIFR3, OCF3A        ; Clear OCF3A by writing a 1 to it
		
		pop r16

            ret                     ; Return from the subroutine
;========================================================================================;
;                         ??????????????????????????????????????                         ;
;                         ?          END DELAY FOR 1S          ?                         ;                                                                            
;                         ??????????????????????????????????????                         ;
;========================================================================================;v










;========================================================================================;
;                         ??????????????????????????????????????                         ;
;                         ?       DISPLAY ROTATED LINE 1       ?                         ;                                                                            
;                         ??????????????????????????????????????                         ;
;========================================================================================;
;                                                                                ;
;    DESCRIPTION:                                                                ;
;            - Displays msg1 with a given offset on the lcd char by char, and    ;
;     	       wrapping the message around once the given offset is large enough ;
;    PARAMETERS:                                                                 ;
;            - msg1_p string in program memory to display                        ;
;			 - r20 given offset to apply to string                   ;
;                                                                                ;        
;    OUTPUT:                                                                     ;
;            - Updates LCD with rotate message                                   ;
;                                                                                ;
;    REGISTERS:                                                                  ;
;            - r16,r23 Used as temporary registers                               ;
;            - r22 used as incrementation counter                                ;
;            - r20 offset parameter                                              ;
;                                                                                ;
;================================================================================;
display_line1_rotated:
	; <-- PROTECT REGISTERS -->
	push ZH
	push ZL
	push r16
	push r20
	push r22
	push r23

	;<-- INITIALIZE Z POINTER TO START OF STRING -->
	ldi ZH, high(msg1_p << 1) ; Set ZH to High byte of string start 
	ldi ZL, low(msg1_p << 1)  ; Set ZL to Low byte of string start
	clr r16                   ; Clear r0 for safety

	;<-- INCREMENT Z POINTER BY OFFSET PARAMETER -->
	ADD ZL, r20      ; Add the low byte of R20 to ZL
	ADC ZH, r16      ; Add the carry to ZH


	; <-- Move Cursor to Origin -->
	ldi r16, 0x00   ; Load Y-Position
	push r16        ; Push Y-Position
	push r16        ; Push X-Position
	call lcd_gotoxy ; Move cursor to origin
	pop r16         ; Pop X parameter
	pop r16         ; Pop Y parameter

	; <-- Initialize Values -->
	clr r16
	clr r22

	put_string1_loop:
		; Check if we've done 16 iterations
		ldi r23, 16      ; Load 16 into r23
		cp r22, r23      ; Compare the iteration counter (R22) with 16
		brge put_string1_end

		lpm R23, Z                          ; load string from program memory

		cpi R23, 0                          ; Check for string null terminator
		brne skip_string1_reset             ; Skip following two lines if null terminator is not found
				ldi ZH, high(msg1_p << 1)   ; Move string pointer back to the start of the string
				ldi ZL, low(msg1_p << 1)    ; Move string pointer back to the start of the string
				rjmp put_string1_loop
		skip_string1_reset:

		push R23                            ; Add char to stack
		call lcd_putchar                    ; Send char to Display
		pop R23 

		adiw Z, 1                           ; Increment string poisition pointer
		inc r22

		rjmp put_string1_loop               ; If not go back to loop

	put_string1_end:
		; <-- RESTORE REGISTERS -->	
		pop r23
		pop r22
		pop r20
		pop r16
		pop ZL
		pop ZH
		ret
;========================================================================================;
;                         ??????????????????????????????????????                         ;
;                         ?     END DISPLAY ROTATED LINE 1     ?                         ;                                                                            
;                         ??????????????????????????????????????                         ;
;========================================================================================;










;========================================================================================;
;                         ??????????????????????????????????????                         ;
;                         ?       DISPLAY ROTATED LINE 2       ?                         ;                                                                            
;                         ??????????????????????????????????????                         ;
;========================================================================================;
;                                                                                ;
;    DESCRIPTION:                                                                ;
;            - Displays msg2 with a given offset on the lcd char by char, and    ;
;     	       wrapping the message around once the given offset is large enough ;
;    PARAMETERS:                                                                 ;
;            - msg2_p string in program memory to display                        ;
;			 - r21 given offset to apply to string                   ;
;                                                                                ;        
;    OUTPUT:                                                                     ;
;            - Updates LCD with rotate message                                   ;
;                                                                                ;
;    REGISTERS:                                                                  ;
;            - r16,r23 Used as temporary registers                               ;
;            - r22 used as incrementation counter                                ;
;            - r21 offset parameter                                              ;
;                                                                                ;
;================================================================================;
display_line2_rotated:
	; <-- PROTECT REGISTERS -->
	push ZH
	push ZL
	push r16
	push r21
	push r22
	push r23

	;<-- INITIALIZE Z POINTER TO START OF STRING -->
	ldi ZH, high(msg2_p << 1) ; Set ZH to High byte of string start 
	ldi ZL, low(msg2_p << 1)  ; Set ZL to Low byte of string start
	clr r16                   ; Clear r0 for safety

	;<-- INCREMENT Z POINTER BY OFFSET PARAMETER -->
	ADD ZL, r21      ; Add the low byte of R21 to ZL
	ADC ZH, r16      ; Add the carry to ZH


	; <-- Move Cursor to Origin -->
	ldi r16, 0x01   ; Load Y-Position
	push r16        ; Push Y-Position
	ldi r16, 0x00
	push r16        ; Push X-Position
	call lcd_gotoxy ; Move cursor to origin
	pop r16         ; Pop X parameter
	pop r16         ; Pop Y parameter

	; <-- Initialize Values -->
	clr r16
	clr r22

	put_string2_loop:
		; Check if we've done 16 iterations
		ldi r23, 16      ; Load 16 into r23
		cp r22, r23      ; Compare the iteration counter (R22) with 16
		brge put_string2_end

		lpm R23, Z		            ; load string from program memory

		cpi R23, 0                          ; Check for string null terminator
		brne skip_string2_reset             ; Skip following two lines if null terminator is not found
				ldi ZH, high(msg2_p << 1)   ; Move string pointer back to the start of the string
				ldi ZL, low(msg2_p << 1)    ; Move string pointer back to the start of the string
				rjmp put_string1_loop
		skip_string2_reset:

		push R23                    ; Add char to stack
		call lcd_putchar            ; Send char to Display
		pop R23 

		adiw Z, 1                   ; Increment string poisition pointer
		inc r22

		rjmp put_string2_loop       ; If not go back to loop

	put_string2_end:
		; <-- RESTORE REGISTERS -->	
		pop r23
		pop r22
		pop r20
		pop r16
		pop ZL
		pop ZH
		ret
;========================================================================================;
;                         ??????????????????????????????????????                         ;
;                         ?     END DISPLAY ROTATED LINE 2     ?                         ;                                                                            
;                         ??????????????????????????????????????                         ;
;========================================================================================;
		



msg1_p:	.db "Dryden Bryson  ", 0	
.equ msg1_length = 15
spacing:	.db "Dryden Bryson  ", 0	
msg2_p: .db "CSC 230: Spring 2025  ", 0
.equ msg2_length = 22

.dseg
;
; The program copies the strings from program memory
; into data memory.  These are the strings
; that are actually displayed on the lcd
;
msg1:	.byte 200
msg2:	.byte 200
