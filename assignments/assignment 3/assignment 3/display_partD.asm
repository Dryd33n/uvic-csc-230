#define LCD_LIBONLY
.include "lcd.asm"

.cseg

; <-- ADC DEFINITIONS -->
	.equ ADCSRA_BTN=0x7A
	.equ ADCSRB_BTN=0x7B
	.equ ADMUX_BTN=0x7C
	.equ ADCL_BTN=0x78
	.equ ADCH_BTN=0x79

; <-- KEYPAD THRESHOLD DEFINITIONS -->
	.equ RIGHT	= 0x032 ; ADC value for RIGHT button
	.equ UP	    = 0x0C3 ; ADC value for UP button
	.equ DOWN   = 0x17C ; ADC value for DOWN button
	.equ LEFT	= 0x22B ; ADC value for LEFT button
	.equ SELECT = 0x316 ; ADC value for SELECT button (not used)

; <-- INITIALIZE STACK POINTER -->
    ldi r16, low(RAMEND)   ; Get RAMEND Low
    out SPL, r16           ; Initialize Stack Pointer Low
    ldi r16, high(RAMEND)  ; Get RAMEND High
    out SPH, r16           ; Initialize Stack Pointer High

; <-- INITIALIZE LED DISPLAY -->
	call lcd_init
	call lcd_clr

; <-- INITIALIZE ADC -->
	call initialize_adc


;                         ╔════════════════════════════════════╗                         ;
;                         ║         MAIN EXECUTION LOOP        ║                         ;                                                                            
;                         ╚════════════════════════════════════╝                         ;
loop:
	call check_button 

	cpi r24, 1
    breq disp_right
    cpi r24, 2
    breq disp_up
    cpi r24, 3
    breq disp_down
    cpi r24, 4
    breq disp_left

	rjmp loop
;                         ╔════════════════════════════════════╗                         ;
;                         ║       END MAIN EXECUTION LOOP      ║                         ;                                                                            
;                         ╚════════════════════════════════════╝                         ;










;========================================================================================;
;                         ╔════════════════════════════════════╗                         ;
;                         ║   DISPLAY MESSAGES BASED ON INPUT  ║                         ;                                                                            
;                         ╚════════════════════════════════════╝                         ;
;========================================================================================;
;                                                                                ;
;    DESCRIPTION:                                                                ;
;            - Displays predefined messages on an LCD screen based on input.     ;
;            - Clears the LCD before displaying the message.                     ;
;                                                                                ;
;    PARAMETERS:                                                                 ;
;            - Each routine selects a specific message to display.               ;
;                                                                                ;
;    OUTPUT:                                                                     ;
;            - LCD displays a message corresponding to the direction.            ;
;                                                                                ;
;    REGISTERS:                                                                  ;
;            - R16  (Used for loading message address and offset parameters)     ;
;                                                                                ;
;================================================================================;


		;<--- DISPLAY LEFT MESSAGE --->
disp_left:
	call lcd_clr                ; Clear LCD display

	push r16                    ; Save R16 to stack

	ldi r16, high(l_msg << 1)    ; Load high byte of left message address
	push r16                    
	ldi r16, low(l_msg << 1)     ; Load low byte of left message address
	push r16
	ldi r16, l_offset            ; Load offset for left message
	push r16
	ldi r16, l_row               ; Load row position for left message
	push r16
	call display_message         ; Call display_message routine
	pop r16                      ; Restore registers
	pop r16
	pop r16
	pop r16
	pop r16

	ret                          ; Return to caller


		;<--- DISPLAY RIGHT MESSAGE --->
disp_right:
	call lcd_clr                ; Clear LCD display

	push r16                    ; Save R16 to stack

	ldi r16, high(r_msg << 1)    ; Load high byte of right message address
	push r16                    
	ldi r16, low(r_msg << 1)     ; Load low byte of right message address
	push r16
	ldi r16, r_offset            ; Load offset for right message
	push r16
	ldi r16, r_row               ; Load row position for right message
	push r16
	call display_message         ; Call display_message routine
	pop r16                      ; Restore registers
	pop r16
	pop r16
	pop r16
	pop r16

	ret                          ; Return to caller


		;<--- DISPLAY UP MESSAGE --->
disp_up:
	call lcd_clr                ; Clear LCD display

	push r16                    ; Save R16 to stack

	ldi r16, high(u_msg << 1)    ; Load high byte of up message address
	push r16                    
	ldi r16, low(u_msg << 1)     ; Load low byte of up message address
	push r16
	ldi r16, u_offset            ; Load offset for up message
	push r16
	ldi r16, u_row               ; Load row position for up message
	push r16
	call display_message         ; Call display_message routine
	pop r16                      ; Restore registers
	pop r16
	pop r16
	pop r16
	pop r16

	rjmp loop                    ; Return to main loop


		;<--- DISPLAY DOWN MESSAGE --->
disp_down:
	call lcd_clr                ; Clear LCD display

	push r16                    ; Save R16 to stack

	ldi r16, high(d_msg << 1)    ; Load high byte of down message address
	push r16                    
	ldi r16, low(d_msg << 1)     ; Load low byte of down message address
	push r16
	ldi r16, d_offset            ; Load offset for down message
	push r16
	ldi r16, d_row               ; Load row position for down message
	push r16
	call display_message         ; Call display_message routine
	pop r16                      ; Restore registers
	pop r16
	pop r16
	pop r16
	pop r16

	rjmp loop                    ; Return to main loop

;========================================================================================;
;                         ╔════════════════════════════════════╗                         ;
;                         ║       END DISPLAY MESSAGES         ║                         ;                                                                            
;                         ╚════════════════════════════════════╝                         ;
;========================================================================================;










;========================================================================================;
;                         ╔════════════════════════════════════╗                         ;
;                         ║          INITIALIZE ADC            ║                         ;                                                                            
;                         ╚════════════════════════════════════╝                         ;
;========================================================================================;
initialize_adc:
	ldi r16, 0x87  
	sts ADCSRA_BTN, r16
	ldi r16, 0x00
	sts ADCSRB_BTN, r16
	ldi r16, 0x40  
	sts ADMUX_BTN, r16
	ret


;========================================================================================;
;                         ╔════════════════════════════════════╗                         ;
;                         ║        BEGIN CHECK BUTTON          ║                         ;                                                                            
;                         ╚════════════════════════════════════╝                         ;
;========================================================================================;
;                                                                                ;
;    DESCRIPTION:                                                                ;
;            - Reads an ADC value to determine which button (if any) is pressed. ;
;            - Buttons correspond to specific voltage thresholds.                ;
;                                                                                ;
;    PARAMETERS:                                                                 ;
;            - None                                                              ;
;                                                                                ;
;    OUTPUT:                                                                     ;
;            - R24 (Returns a value indicating the button pressed):              ;
;                0 -> No button pressed                                          ;
;                1 -> RIGHT button pressed                                       ;
;                2 -> UP button pressed                                          ;
;                3 -> DOWN button pressed                                        ;
;                4 -> LEFT button pressed                                        ;
;                                                                                ;
;    REGISTERS:                                                                  ;
;            - R16 (Temporary storage for ADC control register)                  ;
;            - R17 (Temporary storage for high byte comparison)                  ;
;            - R24 (Stores ADC low byte and result)                              ;
;            - R25 (Stores ADC high byte)                                        ;
;                                                                                ;
;================================================================================;
check_button:
    ; --- START ADC CONVERSION ---
    lds R16, ADCSRA_BTN       ; Load ADC control register
    ori R16, 0x40             ; Start ADC conversion
    sts ADCSRA_BTN, R16       ; Store back to control register

    ; --- WAIT FOR CONVERSION TO COMPLETE ---
    wait:
        lds R16, ADCSRA_BTN   ; Read ADC control register
        andi R16, 0x40        ; Check if conversion is still running
        brne wait             ; If still running, wait

    ; --- READ ADC RESULT ---
    lds R24, ADCL_BTN         ; Load ADC low byte
    lds R25, ADCH_BTN         ; Load ADC high byte

    ; --- CHECK BUTTON THRESHOLDS ---
    check_right:
        ldi R16, low(RIGHT)   ; Load low byte of RIGHT threshold
        ldi R17, high(RIGHT)  ; Load high byte of RIGHT threshold
        cp R24, R16           ; Compare low bytes
        cpc R25, R17          ; Compare high bytes
        brsh check_up         ; If ADC >= RIGHT, check next
        ldi R24, 1            ; RIGHT button pressed
        ret

    check_up:
        ldi R16, low(UP)      ; Load low byte of UP threshold
        ldi R17, high(UP)     ; Load high byte of UP threshold
        cp R24, R16           ; Compare low bytes
        cpc R25, R17          ; Compare high bytes
        brsh check_down       ; If ADC >= UP, check next
        ldi R24, 2            ; UP button pressed
        ret

    check_down:
        ldi R16, low(DOWN)    ; Load low byte of DOWN threshold
        ldi R17, high(DOWN)   ; Load high byte of DOWN threshold
        cp R24, R16           ; Compare low bytes
        cpc R25, R17          ; Compare high bytes
        brsh check_left       ; If ADC >= DOWN, check next
        ldi R24, 3            ; DOWN button pressed
        ret

    check_left:
        ldi R16, low(LEFT)    ; Load low byte of LEFT threshold
        ldi R17, high(LEFT)   ; Load high byte of LEFT threshold
        cp R24, R16           ; Compare low bytes
        cpc R25, R17          ; Compare high bytes
        brsh no_button        ; If ADC >= LEFT, no button pressed
        ldi R24, 4            ; LEFT button pressed
        ret

    no_button:
        clr R24               ; No button pressed
        ret
;========================================================================================;
;                         ╔════════════════════════════════════╗                         ;
;                         ║        END CHECK BUTTON            ║                         ;                                                                            
;                         ╚════════════════════════════════════╝                         ;
;========================================================================================;










;========================================================================================;
;                         ╔════════════════════════════════════╗                         ;
;                         ║        BEGIN DISPLAY MESSAGE       ║                         ;                                                                            
;                         ╚════════════════════════════════════╝                         ;
;========================================================================================;
;                                                                                ;
;    DESCRIPTION:                                                                ;
;            - Displays a null-terminated string on an LCD screen at a given     ;
;              row and column.                                                   ;
;                                                                                ;
;    PARAMETERS:                                                                 ;
;            - 1 Byte Pushed to Stack (Row position of the string)               ;
;            - 1 Byte Pushed to Stack (Column position of the string)            ;
;            - 2 Bytes Pushed to Stack (Pointer to the null-terminated string)   ;
;                                                                                ;
;    OUTPUT:                                                                     ;
;            - Writes characters to the LCD screen.                              ;    
;                                                                                ;
;    REGISTERS:                                                                  ;
;            - R16    (Stores the row position)                                  ;
;            - R17    (Stores the column position)                               ;
;            - R18    (Stores the first character of the string)                 ;
;            - R21    (Temporarily holds characters for printing)                ;
;            - ZL/ZH  (Stores the pointer to the string in program memory)       ;
;                                                                                ;
;================================================================================;
display_message:
    ; --- INITIALIZATION ---
    in YL, SPL                 ; Store Low Stack Pointer from SRAM Stack Region to Y-Low
    in YH, SPH                 ; Store High Stack Pointer from SRAM Stack Region to Y-High
    clr R16                    ; Clear R16
    ldd R16, Y+4               ; Load Row position from stack
    ldd R17, Y+5               ; Load Column position from stack
    ldd ZL, Y+6                ; Load Low byte of string address
    ldd ZH, Y+7                ; Load High byte of string address

    lpm R18, Z                 ; Load first character of the string from program memory

    ; --- SET CURSOR POSITION ---
    push R16                   ; Save row parameter to stack
    push R17                   ; Save column parameter to stack
    call lcd_gotoxy            ; Set cursor position on LCD
    pop R17                    ; Restore column parameter
    pop R16                    ; Restore row parameter

    ; --- DISPLAY LOOP ---
    disp_loop:
        lpm R21, Z             ; Load character from program memory
        cpi R21, 0             ; Check for null terminator
        breq return            ; If null terminator found, exit loop

        push R21               ; Save character to stack
        call lcd_putchar       ; Print character to LCD
        pop R21                ; Restore character from stack

        adiw Z, 1              ; Increment string pointer

        rjmp disp_loop         ; Repeat for next character

    ; --- RETURN ---
    return:
        jmp loop               ; Jump to main loop

    ret
;========================================================================================;
;                         ╔════════════════════════════════════╗                         ;
;                         ║        END DISPLAY MESSAGE         ║                         ;                                                                            
;                         ╚════════════════════════════════════╝                         ;
;========================================================================================;




;========================================================================================;
;                         ╔════════════════════════════════════╗                         ;
;                         ║       PROGRAM MEMORY SEGMENT       ║                         ;                                                                            
;                         ╚════════════════════════════════════╝                         ;
;========================================================================================;
l_msg:	.db "Left", 0
.equ l_row = 1
.equ l_offset = 0

r_msg: .db "Right", 0
.equ r_row = 1
.equ r_offset = 11

u_msg: .db "Up", 0
.equ u_row = 0
.equ u_offset = 7

d_msg: .db "Down", 0
.equ d_row = 1
.equ d_offset = 6	
