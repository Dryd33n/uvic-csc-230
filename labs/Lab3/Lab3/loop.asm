/*
 * loop.asm
 *
 *  Created: 1/31/2025 11:37:11 AM
 *   Author: dryd3n
 */ 
 .cseg
 .org 0

 .def counter=r17
	ldi count,0

loop:
	inc count        ; increment counter
	cpi count, 0x04  ; perform comparison between counter and 4, i.e counter - 4
	breq done        ; if result of counter - 4 is 0 then branch to done
	rjmp loop		 ; jump back to loop

done: rjmp done