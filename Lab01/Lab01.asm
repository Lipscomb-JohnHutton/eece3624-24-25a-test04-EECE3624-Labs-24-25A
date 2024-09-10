
/**************************************************************************
 *      File: Lab01.asm
 *  Lab Name: Ready, Set, Go!
 *    Author: Dr. Greg Nordstrom
 *   Created: 1/11/2021
 *  Modified: 
 * Processor: ATmega128A (on the ReadyAVR board)
 *
 * This program verifies the operation of the ReadyAVR-64/128 board.
 * This board has an ATmega128A processor, on-board LEDs, joystick, and
 * a prototyping area. It also contains a USB-to-UART bridge chip which
 * allows the USB connector to provide an RS232 connection to a PC-based
 * terminal program, and a JTAG port for code debugging.
 *
 * Steps to check out the board:
 *  1. Set the J2 jumpers to enable USART1 communication (PD2 and PD3)
 *     (NB: PD2 and PD3 are jumpered by default on new ReadyAVR boards.)
 *  2. Attach the Atmel-ICE programmer to the board's JTAG port. Pay
 *     very close attention to the connector orientation. IMPORTANT!
 *  3. Connect the board to the PC using a USB A/B cable
 *  4. Open PuTTY on the PC, set it to the proper COM channel (use the
 *     Windows Device Manager to determine this value), and configure it
 *     for 9600N81 (9600 baud, no parity, 8 data bits, 1-bit stop bit).
 *     Set Local echo to "Force off" and Local line editing to "Auto").
 *  5. Compile and download the code with Atmel Studio.
 *  6. As soon as the code runs, the welcome message will be displayed
 *     on PuTTY. To see the program in action, begin typing characters
 *     in the PuTTY window and notice that all printable characters are
 *     displayed and that non-printable characters (e.g. Enter, Backspace,
 *     etc.) operate as expected.
 *
 *************************************************************************/ 

; equates
.EQU CR  = 0x0D
.EQU LF  = 0x0A
.EQU NUL = 0x00
 
.org 0x0000 ; next instruction will be written to address 0x0000 (reset vector)
rjmp main   ; set reset vector to point to the main code entry point below

; jump here on reset
main:

; initialize the stack (RAMEND = 0x10FF by default)
ldi r16, high(RAMEND)
out SPH, r16
ldi r16, low(RAMEND)
out SPL, r16

; set portc.0 pin as output for LED "blink" when a character is received
ldi R16, (1<<DDC0)  ; <- this is the preferred way to say: ldi R16, 0b00000001
out DDRC, R16

; turn off LED0 (set bit zero of port C to 1)
sbi PORTC, DDC0

; initialize the USART hardware (9600 N81)
rcall USART_Init

; send welcome message to terminal
rcall Display_Welcome

; loop forever, reading a char from terminal and writing it out again
mainLoop:
    rcall USART_Receive
    rcall LED_Blink
    rcall USART_Transmit
    rjmp mainLoop

/************************************************************************
 * Subroutines start here
 ************************************************************************/
Display_Welcome:
    ; load address of welcome message into Z register
    ldi ZH, high(WelcomeMessage<<1)    ; double value since program memory is organized
    ldi ZL, low(WelcomeMessage<<1)     ; in 16-bit words, but we want byte address

    GetNextChar:
    lpm r16, Z+                        ; get character pointed to by Z into r16 and increment Z for next fetch

    ; check for end of message
    tst r16                            ; NUL char?
    breq DisplayDone                   ; if so, leave

    ; send char to terminal
    rcall USART_Transmit

    rjmp GetNextChar

    DisplayDone:
ret


LED_Blink:
    ; turn ReadyAVR LED0 on by clearing PortC, bit 0 (active low)
    cbi PORTC, 0

    ; leave LED0 on for 40mSec (short "blip")
    rcall delay10mS;
    rcall delay10mS;
    rcall delay10mS;
    rcall delay10mS;

    ; turn LED0 off by setting Port C, bit 0
    sbi PORTC, DDC0
ret

USART_Init:
    ; Set baud rate to 9600 (UBRRn = 47 for ReadyAVR clock)
    ldi r17, 0
    ldi r16, 47
    sts UBRR1H, r17
    sts UBRR1L, r16

    ; Enable receiver and transmitter via USART Control and Status Register B (for USART 1)
    ldi r16, ((1<<RXEN1)|(1<<TXEN1))  ; set bits 4 (RXEN) and 3 (TXEN) to enable Rx and Tx hardware
    sts UCSR1B, r16

    ; Set frame format: async, no parity, 8-bit data, 1 stop bit via USART Control and Status Register C (for USART 1)
    ldi r16, ((0<<UMSEL1) | (0<<UPM11) | (0<<UPM10) | (0<<USBS1) | (1<<UCSZ11) | (1<<UCSZ10) | (0<<UCPOL1))
    sts UCSR1C, r16
ret

USART_Transmit:
    ; Wait for empty transmit buffer
    lds r17, UCSR1A      ; get status of Tx buffer
    sbrs r17, UDRE1      ; if Tx buffer is empty (i.e. if bit UDRE1 = 1), skip next step and send new char
    rjmp USART_Transmit  ; Tx buffer not empty, so loop back and check it again

    sts UDR1, r16        ; send the char by writing it to UDR1

    ; if a CR (0x1D) was sent, also send an LF (0x10).
    cpi r16, CR          ; was last char sent a CR?
    breq Send_LF         ; if so, skip ahead and send an LF, too
    ret                  ; if not, return
Send_LF:
    lds r17, UCSR1A
    sbrs r17, UDRE1
    rjmp Send_LF         ; loop back until Tx buffer is empty
    ldi r16, LF   
    sts UDR1, r16        ; send the "extra" LF char    
ret

USART_Receive:
    ; Wait for data to be received
    lds r17, UCSR1A      ; get USART1 Control and Status Register A
    sbrs r17, RXC1       ; if Rx buffer contains unread data (i.e. if RXC1 bit = 1), skip next step and read the char
    rjmp USART_Receive

    lds r16, UDR1        ; receive the char by reading it from UDR1
ret

/**************************************************************************
 * Name: delay10mS
 *
 * This subroutine causes a time delay of 10mS by wasting appx 73728 cycles,
 * assuming the processor clock is running at 7.3728Mhz.
 *************************************************************************/ 
delay10mS:
    ldi R18, 10                     ; 1 cycle
    outer_loop:
        ; code inside outer_loop takes 1+1+((2+2)*r24:r25)-1+1+2 cycles
        ; (code outside outer_loop adds 1-1+4 cycles)
        ; If r24:r25=1998, entire subroutine takes 10*(8+(2+2)*1841) = 73,720 cycles
        ldi R24, low(1841)          ; 1 cycle
        ldi R25, high(1841)         ; 1 cycle
        inner_loop:
            sbiw R24, 1             ; 2 cycles; subtracts 1 from r24:r25 (equivalent to "dec r25:r24")
            brne inner_loop         ; 2 cycles if branch taken (true), 1 cycle if branch not taken(false)
        dec R18                     ; 1 cycle
        brne outer_loop             ; 2 cycles if branch taken (true), 1 cycle if branch not taken(false)
    ret                             ; 4 cycles


; welcome message text
; NB: Must ensure that each line has an EVEN NUMBER OF CHARACTERS
WelcomeMessage:
.DB "RS232 Echo Server (ATmega128A, USART1) ",CR
.DB "Status: Active ",CR
.DB "EECE3624, Spring 2021 ",CR,CR
.DB "Begin typing in the area below.", CR
.DB "LED0 will blink when you type a character. ", CR,CR,NUL