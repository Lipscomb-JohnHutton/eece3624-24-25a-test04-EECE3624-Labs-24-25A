/**************************************************************************
 *	    File: Lab02.asm
 *  Lab Name: In the Blink of an Eye
 *    Author: Dr. Greg Nordstrom
 *   Created: 1/13/2021
 * Processor: ATmega128A (on the ReadyAVR board)
 *
 * Modified by: <Your name goes here>
 * Modified on: <Date modified goes here>
 *
 * This program flashes LED3 (attached to PORTC, pin 3) with a duty cycle
 * of 50% (equal on and off times). To determine the clock speed, you must
 * determine the blink rate by timing the number of blinks in one second.
 * Then you can use cycle counting to analyze the code below and determine
 * the clock speed of the processor.
 *
 * NB: Atmel Studio project created with ATMega128A processor. The last "A"
 * stands for "Advanced performance," as compared to the ATMega128 which
 * is the "normal" performace processor. Same programming model in both.
 *************************************************************************/ 

.org 0x0000 ; next instruction will be written to address 0x0000
            ; (the location of the reset vector)
rjmp main   ; set reset vector to point to the main code entry point

main:       ; jump here on reset

    ; initialize the stack (RAMEND = 0x10FF by default)
    ldi R16, HIGH(RAMEND)
    out SPH, R16
    ldi R16, low(RAMEND)
    out SPL, R16

    ; set PORTC.3 pin as output via PORTC's Data Direction Register
    ldi R16, (1<<DDC3)  ; R16 = 0b00001000 (bit 3 set to high)
    out DDRC, R16       ; DDRC = 0b00001000, making PORTC.3 an output pin

    ; set bit 3 of PORTC to turn off the LED (active low)
    sbi PORTC, PORTC3

mainLoop:
    ; clear bit 3 of PORTC to turn on LED (active low)
    cbi PORTC, PORTC3

    ; kill some time
    ldi R16, 40                 ; R16 is outer loop counter
outer_loop1:
    ldi R24, low(0x4000)        ; load low and high parts of R25:R24 pair with
    ldi R25, high(0x4000)       ; loop count by loading registers separately
    inner_loop1:
        sbiw R24, 1             ; decrement inner loop counter (R25:R24 pair)
        brne inner_loop1        ; loop back if R25:R24 isn't zero
    dec R16                     ; decrement the outer loop counter (R16)
    brne outer_loop1            ; loop back if R16 isn't zero

    ; turn off LED (set bit 3 of PORTC)
    sbi PORTC, PORTC3

    ; kill some time
    ldi R16, 40                 ; R16 is outer loop counter
outer_loop2:
    ldi R24, low(0x4000)        ; load low and high parts of R25:R24 pair with
    ldi R25, high(0x4000)       ; loop count by loading registers separately
    inner_loop2:
        sbiw R24, 1             ; decrement inner loop counter (R25:R24 pair)
        brne inner_loop2        ; loop back if R25:R24 isn't zero
    dec R16                     ; decrement the outer loop counter (R16)
    brne outer_loop2            ; loop back if R16 isn't zero

; play it again, Sam...
    rjmp mainLoop
