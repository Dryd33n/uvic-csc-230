.cseg
.org 0 

	;set PORTL and PORTB as output
	ldi r16, 0xFF
	sts DDRL, r16
	out DDRB, r16

	;Turn on the following LEDS [*][][*][*][][*]
	ldi r16, 0b10001010
	sts PORTL, r16
	ldi r16, 0b00000010
	out PORTB, r16

done: jmp done