# 6809-Micro-Calculator
HARDWARE
- 6809 microprocessor based calculator, 1mHz , 
Memory map = 0000H - 7fff Ram
8000H - 801f input output decode
E000H - FFFFH ROM program
Board includes single step circuit, monostable one shot reset circuit,
Address and data are displayed using 74HC273 latches, and TIL311 hex displays
Latches are triggered when the the bus available signal goes low, 74HC123 one adjusted for 2 msec to capture instruction location and data.
Latches are required since adress and data tristate outputs turn off when processor is in halt mode
Each value for the calculator display is latched with a 4 bit  74HC173 , and each digit multiplexed 
Digits are decoded with 74ls47 ic, and a 4 digits common anode display was used
Keypad decode using a 74C923 ic and data available is pulsed to the interupt input of the 6809
