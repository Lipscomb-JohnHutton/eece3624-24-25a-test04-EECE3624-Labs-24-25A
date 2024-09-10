# Lab01
Welcome! In this lab you'll be introduced to the ReadyAVR-64/128 board. This board has an ATmega128A processor, on-board LEDs, joystick, and a prototyping area. It also contains a USB-to-UART bridge chip which allows the USB connector to provide an RS232 connection to a PC-based terminal program (such as PuTTY), and a JTAG port for code debugging.

Steps to check out the board:
  1. Set the J2 jumpers to enable USART1 communication (PD2 and PD3)
     (NB: PD2 and PD3 are jumpered by default on new ReadyAVR boards.)
  2. Attach the Atmel-ICE programmer to the board's JTAG port. Pay
     very close attention to the connector orientation. IMPORTANT!
  3. Connect the board to the PC using a USB A/B cable.
  4. Open PuTTY on the PC, set it to the proper COM port channel.
     You can use Windows Device Manager to determine which COM ports
	 are in use or simply run Dr. Nordstrom's handy "comports.bat" 
	 batch file (also found in this repo). Configure PuTTY for
     9600N81 (9600 baud, no parity, 8 data bits, 1-bit stop bit),
     set Local echo to "Force off" and Local line editing to "Auto".
  5. Compile and download the code into the ReadyAVR with Atmel Studio.
  6. As soon as the code runs, the welcome message will be displayed
     on PuTTY. To see the program in action, begin typing characters
     in the PuTTY window and notice that all printable characters are
     displayed and that non-printable characters (e.g. Enter, Backspace,
     etc.) operate as expected.

Have fun!
