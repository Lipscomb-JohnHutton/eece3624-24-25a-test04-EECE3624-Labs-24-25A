@ECHO OFF
Rem Shows available COM ports
ECHO COM ports currently in use are:
PowerShell.exe -Command "[System.IO.Ports.SerialPort]::getportnames()"
PAUSE