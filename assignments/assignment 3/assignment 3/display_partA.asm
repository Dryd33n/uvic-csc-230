#define LCD_LIBONLY
.include "lcd.asm"

.cseg
;                         ╔════════════════════════════════════╗                         ;
;                         ║           INITIALIZATION           ║                         ;                                                                            
;                         ╚════════════════════════════════════╝                         ;
    ; <-- TIMER DEFINITIONS FOR 1S DELAY -->
    .equ CLOCK     = 16000000
    .equ PRESCALER = 1024
    .equ DELAY     = 1
    .equ TOP       = int(0.5+(CLOCK/PRESCALER*DELAY))

    ; <-- INITIALIZE STACK POINTER -->
    ldi r16, low(RAMEND)   ; Get RAMEND Low
    out SPL, r16           ; Initialize Stack Pointer Low
    ldi r16, high(RAMEND)  ; Get RAMEND High
    out SPH, r16           ; Initialize Stack Pointer High

    ; <-- INITIALIZE TIMER -->
    rcall timer_init

    call lcd_init			; call lcd_init to Initialize the LCD
    call init_strings                   ; load strings into data memory


;                         ╔════════════════════════════════════╗                         ;
;                         ║        MAIN EXECUTION LOOP         ║                         ;                                                                            
;                         ╚════════════════════════════════════╝                         ;
    ; <-- ENTER MAIN LOOP -->
    loop:
	; -- DISPLAY BOTH LINES --
	rcall display_line1
        rcall display_line2
        rcall delay_1s

	; -- DISPLAY FIRST LINE --
        call lcd_clr
        rcall display_line1
        rcall delay_1s

	; -- DISPLAY SECOND LINE
        call lcd_clr
        rcall display_line2
        rcall delay_1s

        rjmp loop










;========================================================================================;
;                         ╔════════════════════════════════════╗                         ;
;                         ║          INTIAILIZE TIMER          ║                         ;                                                                            
;                         ╚════════════════════════════════════╝                         ;
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
        ; <-- SET TOP VALUE -->
        ldi r16,     high(TOP)        ; Load High value of TOP
        ldi r17,     low(TOP)         ; Load Low value of TOP
        sts OCR3AH,  r16              ; Set High value of TOP
        sts OCR3AL,  r17              ; Set Low value of TOP
        
        ; <-- DISABLE PWM MODE -->
        ldi r16, 0                    ; Load 0 as configuration for PWM 
        sts TCCR3A, temp              ; Set 0 as configuration for PWM
    ret   
;========================================================================================;
;                         ╔════════════════════════════════════╗                         ;
;                         ║        END INTIAILIZE TIMER        ║                         ;                                                                            
;                         ╚════════════════════════════════════╝                         ;
;========================================================================================;










;========================================================================================;
;                         ╔════════════════════════════════════╗                         ;
;                         ║            DELAY FOR 1S            ║                         ;                                                                            
;                         ╚════════════════════════════════════╝                         ;
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

            ret                     ; Return from the subroutine
;========================================================================================;
;                         ╔════════════════════════════════════╗                         ;
;                         ║          END DELAY FOR 1S          ║                         ;                                                                            
;                         ╚════════════════════════════════════╝                         ;
;========================================================================================;






















display_line1:
    push r16


	ldi r16, 0x00
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display msg1 on the first line
	ldi r16, high(msg1)
	push r16
	ldi r16, low(msg1)
	push r16
	call lcd_puts
	pop r16
	pop r16

    pop r16
	ret

display_line2:
    push r16

    	ldi r16, 0x01
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display msg2 on the second line
	ldi r16, high(msg2)
	push r16
	ldi r16, low(msg2)
	push r16
	call lcd_puts
	pop r16
	pop r16

    pop r16
	ret

init_strings:
	push r16
	; copy strings from program memory to data memory
	ldi r16, high(msg1)		; this the destination
	push r16
	ldi r16, low(msg1)
	push r16
	ldi r16, high(msg1_p << 1) ; this is the source
	push r16
	ldi r16, low(msg1_p << 1)
	push r16
	call str_init			; copy from program to data
	pop r16					; remove the parameters from the stack
	pop r16
	pop r16
	pop r16

	ldi r16, high(msg2)
	push r16
	ldi r16, low(msg2)
	push r16
	ldi r16, high(msg2_p << 1)
	push r16
	ldi r16, low(msg2_p << 1)
	push r16
	call str_init
	pop r16
	pop r16
	pop r16
	pop r16

	pop r16
	ret

msg1_p:	.db "Dryden Bryson", 0	
msg2_p: .db "CSC 230: Spring", 0

.dseg
;
; The program copies the strings from program memory
; into data memory.  These are the strings
; that are actually displayed on the lcd
;
msg1:	.byte 200
msg2:	.byte 200

