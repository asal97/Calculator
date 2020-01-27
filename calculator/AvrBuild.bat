@ECHO OFF
del "c:\users\10\downloads\uni\microprocessor-master\calculator\calculator.map"
del "c:\users\10\downloads\uni\microprocessor-master\calculator\labels.tmp"
"C:\Program Files (x86)\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "c:\users\10\downloads\uni\microprocessor-master\calculator\labels.tmp" -fI  -o "c:\users\10\downloads\uni\microprocessor-master\calculator\calculator.hex" -d "c:\users\10\downloads\uni\microprocessor-master\calculator\calculator.obj" -e "c:\users\10\downloads\uni\microprocessor-master\calculator\calculator.eep" -m "c:\users\10\downloads\uni\microprocessor-master\calculator\calculator.map" -W+ie   "C:\Users\10\Downloads\UNI\microProcessor-master\calculator\Calculator.asm"
