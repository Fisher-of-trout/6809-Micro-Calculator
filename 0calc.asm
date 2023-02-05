; 6809 Calculator Program
; created 2022-12-14
; tested 2023-02-04
; revc , multiplication, division, square root functional
; 2 x 2 digits and division 2/2 digits, square root 99 decimal maximum
; assembled with SBassembler
		.cr 6809
		.tf 0calc.hex,INT
		.lf 0calc
        .ORG $e000 
		.ta $0000
				
DIGIT0      .EQU     $8000 ;ones digit ascii output
DIGIT1      .EQU     $8001 ;tens digit ascii output
DIGIT2      .EQU     $8002 ;hundreds digit ascii output
DIGIT3      .EQU     $8003 ;thousands digit ascii output
INPUT       .EQU     $8008 ;character input in hex

Breg .equ $8
Creg .equ $9
Dreg .equ $10
Ereg .equ $11
Hreg .equ $18
Lreg .equ $19
multiplicandMSB .equ $020
multiplicandLSB .equ $021
multiplierMSB .equ $028   
multiplierLSB .equ $029
hexnum .equ $30

dividend .equ $40 ; dividend 16 bits
divisor .equ $42 ;16 bits
remainder .equ $44 ;8 bits in msb
quotient .equ $46 ;16 bits, answer in lsb
quotientlsb .equ $47 ;8 bits, the answer	
divcounter .equ $48 ;8bits  	countdown from 16 decimal

SQnum .equ $70
SQresult .equ $72
ODDnum .equ $74

ACTION     	.EQU     $100 ; store function code to equal action
FUNC        .EQU     $102 ; input Function buffer
DIGPOINT    .EQU     $104 ; digit pointer
OUTPUT      .EQU     $106 ; output buffer
DISPOINT    .EQU     $108 ; display pointer
Keycount    .equ     $110 ; keystrokes
count 		.equ 	 $112 ; amount of 8 bit values to be added

SECV        .equ     $113 ; second value set flag

BUF0        .EQU     $120 ;ones digit
BUF1        .EQU     $121 ;tens digit
BUF2        .EQU     $122 ;hundreds digit
BUF3        .EQU     $123 ;thousands digit
BUF4        .EQU     $124 ;ones digit SECOND VALUE
BUF5        .EQU     $125 ;tens digit SECOND VALUE
BUF6        .EQU     $126 ;hundreds digit SECOND VALUE
BUF7        .EQU     $127 ;thousands digit SECOND VALUE
value1MSB 	.equ 	$130  ;msb of first value to be calculated in BCD
value1LSB 	.equ 	$131 ;lsb of first value to be calculated in BCD
value2MSB 	.equ 	$138  ;msb of second value to be calculated in BCD
value2LSB	.equ 	$139 ;lsb of second value to be calculated in BCD
SUM 		.equ 	$141 ;the answer
;SETUP on boot
            lds #$7ffe
            ldu #$7f00
			jsr clearbuf ;clear buffers
			clr keycount
			clr SECV
			clr func
			ldx #buf0
			stx digpoint ;load digit pointer
			lda #$2
			sta count ; setup two 8 bit values to added
;			orcc #%00010000 ; disable interupt
; MAIN LOOP			
loop     ldb func ;load function code for comparison
		cmpb #$0a
		bne n1
		jsr SQroot
n1   cmpb #$0b
		bne n2
		jsr percent
n2   cmpb #$0c 
		bne n3
		jsr plus
n3   cmpb #$0d 
		bne n4
		jsr minus 
n4   cmpb #$0e 
		bne n5
		jsr multiply
n5   cmpb #$0f 
		bne n6
		jsr divide 
n6   cmpb #$10 
		bne n7
		jsr plusminus 
n7   cmpb #$11 
		bne n8
		jsr period 
n8   cmpb #$12 
		bne n9
		jsr delete
n9   cmpb #$13 
		bne n10
		jsr equal	
n10	nop
       JSR DISPLAY
		andcc #$ef ;clear interupt flag
        jmp loop
		
;If the result is an integer, the less known way is to subtract consecutive odd numbers till zero. 
;Number of subtracts is the square.
;Eg. 25 - 1 = 24, 24 - 3 = 21, 21 -5 = 16, 16 - 7 = 9, 9 - 9 = 0. Five subracts so root is 5.
;perfect sq decimal 4, 9, 16, 25, 36, 49, 64, 81, 100, 121, 144, 169, 196, 225
;perfect sq hex     4, 9, 10, 19, 24, 31, 40, 51, 64,  79,  90,  a9,  c4,  e1
; only converts max 99 decimal because BCD input conversion is only 2 digits  		
SQroot nop
	clr hexnum ;clear hexidecimal result register
	jsr bcd2bin1
    lda sqnum
    ldb #1
    stb oddnum
back    suba oddnum ;subtract accA with totalized oddnumber
    beq ahead ; result equal ?
    bls DECby1 ;result less than ?
    inc ODDnum
    inc ODDnum ;increment 2 times for an odd number
    incb
    jmp back

DECby1    decb ;decrement result by 1 if imperfect square
ahead   nop
    stb Sqresult
	stb hexnum+1 ; store result hexidecimal
	jsr bcdconvert
	jsr sumdisplay
	clr keycount ;reset keycount
	clr func
       rts
	   
percent nop
    lda #1
    sta secv ; set the second value flag
	clr keycount ;reset keycount
	stb action
	clr func
       rts
plus nop
    lda #1
    sta secv ; set the second value flag
	clr keycount ;reset keycount
	stb action
	clr func
    rts
minus nop

    lda #1
    sta secv ; set the second value flag
	clr keycount ;reset keycount
	stb action
	clr func
       rts	   
multiply nop
    lda #1
    sta secv ; set the second value flag
	clr keycount ;reset keycount
	stb action
	clr func
       rts
divide nop
    lda #1
    sta secv ; set the second value flag
	clr keycount ;reset keycount
	stb action
	clr func
       rts
plusminus nop
    lda #1
    sta secv ; set the second value flag
	clr keycount ;reset keycount
	stb action
	clr func
       rts
period nop
    lda #1
    sta secv ; set the second value flag
	clr keycount ;reset keycount
	stb action
	clr func
       rts
delete nop
		
			ldx #buf0
			stx digpoint ;reset digit pointer
			clr secv ; clear second value flag
			jsr clearbuf
			clr func
			rts
equal nop
            jsr ldV1LSB_2
            jsr ldV1MSB_2
            jsr ldV2LSB_2
            jsr ldV2MSB_2
			
			ldb action ;load function code from buffer

			cmpb #$0c 
			bne e1 ;addition ?
			jsr addition
e1			cmpb #$0d ;subtraction?
			bne e2 ;exit
			jsr subtract
e2			cmpb #$0e ;multiplication?
			bne e3 ;exit
			jsr multiplication			
e3			cmpb #$0f ;division?
			bne e10 ;exit
			jsr division			
			
e10		nop
		rts	

addition nop
		ldb count ;amount of 8 bit values to be added
		ANDCC #$FE ;clear carry
		ldx #value1LSB ;load start address of values
		ldy #sum ;load start address of sum
p1 		lda ,x ;load value from index pointer
		adca $8,x ; add with carry
		daa ; adjust for decimal
		sta ,y ;store sum via index pointer
		LEAX -1,x ;dec sum pointer
		LEAY -1,y ;dec value pointer
		decb 
		bne p1 ; all values added ?
		clr secv ;clear second value display flag
		jsr sumdisplay
		clr func ; clear the input character
		clr action
        rts	
		
SUBTRACT nop
		ANDCC #$FE ;clear carry
		ldx #value1lSB ;load start address of values
		ldy #sum ;load start address of difference
		lda #$99 ;add largest decimal number 9's compliment
		sbca $8,x ; subract subrahend LSB with borrow
		adda ,x ;add minuend LSB via index pointer
		inca ; increment accumulator/ negate borrow
		daa ; adjust for decimal
		sta ,y ;store difference LSB  
		lda #$99 ;add largest decimal number 9's compliment
		suba 7,x ; subract subrahend MSB WITHOUT borrow
		adda -1,x ;add minuend LSB via index pointer
		inca ; increment accumulator
		daa ; adjust for decimal
		sta -1,y ;store differnce  MSB 
		clr secv ;clear second value display flag
		jsr sumdisplay
		clr func
		clr action
		rts
MULTIPLICATION nop
		jsr bcd2bin1
		jsr bcd2bin2
		lda multiplierLSB
		ldb multiplicandLSB
		mul
		std hexnum ; store Product in hexidecimal
		jsr bcdconvert
		clr secv ;clear second value display flag
		jsr sumdisplay
		clr func
		clr action
		rts

DIVISION nop
		jsr bcd2bin1 ;convert BCD to Binary value1 lsb
		jsr bcd2bin2 ;convert BCD to Binary value2 lsb
		lda #$10 ;initialize divide counter to 16 decimal
		sta divcounter
        clr remainder       
        clr remainder+1
        clra
        clrb
divd    asl DIVIDEND+1
        rol DIVIDEND
        rolb
        rola
        cmpd divisor ;divisor > divisor?
        blo nosub
        subd divisor ;divisor, subtract and set bit in quotient
        inc DIVIDEND+1
nosub   dec  divcounter ; count-1
        bne divd
        std remainder ; store remainder . most sig byte
		ldy DIVIDEND
        sty quotient ;the answer
		sty hexnum ;store in hex number buffer to be converted
		jsr bcdconvert
		clr secv ;clear second value display flag
		jsr sumdisplay
		clr func
		clr action
		clr DIVIDEND       
        clr DIVIDEND+1
		RTS
		
; routine to convert hex to bcd value (adapted from a 8085 routine)
;for output display
BCDCONVERT    ldy hexnum ;load hex number to be converted to bcd
		clra ;clear all registers
		clrb
		clr Breg
		clr Creg
		clr Dreg
		clr Ereg
		clr Hreg
		clr Lreg
loop1 	adda #1
		daa
		sta Breg ;trans acca to B register
		bcc skip ; branch if carry =0
		lda Ereg ; move e reg to acca
		adda #1
		daa
		sta Ereg ; store acca in e register
		bcc skip ; branch if carry =0
		lda Dreg ; move d register to acca
		adda #1
		daa
		sta Dreg ; store acca to d register
skip    nop 
		leay -1,y ;decrement index register (hexnumber)
		sty Hreg ;store in HL register
		lda Hreg
		ora Lreg
		lda Breg
		ldx Hreg
		bne loop1 ;check for zero flag, hexnum at zero?
		ldb Ereg
		stb sum-1 ;resultmsb
		sta sum ;resultlsb
		rts

bcd2bin1 nop
		lda buf1 ;load most significat digit
		ldb #10 ; load 10 decimal
		mul ; multiply
		addb buf0 ; add least significant digit
		stb multiplicandLSB ; store hex value of bcd input
		stb dividend+1 ;store dividend lsb in hex
		stb SQnum
		rts
	
bcd2bin2 nop
		lda buf5 ;load most significat digit
		ldb #10 ; load 10 decimal
		mul ; multiply
		addb buf4 ; add least significant digit
		stb multiplierLSB ; store hex value of bcd input
;		stb divisor
		stb divisor+1 ;store dividend lsb in hex
		rts
		
; load results into display buffers
sumdisplay nop
		jsr clearbuf
		clr secv ;clear second value display flag
		lDA sum
		sta buf0
		lsra
		lsra
		lsra
		lsra
		sta buf1
		lDA sum-1
		sta buf2
		lsra
		lsra
		lsra
		lsra
		sta buf3	
		rts
	   
; Display subroutine            
display ldb SECV ; check for second value flag
        cmpb #$1
        beq d1 ;flag set, yes , display second value
        lda buf0	;this subroutine works
		sta DIGIT0
		jsr delay
		lda buf1
		sta DIGIT1
		jsr delay
		lda buf2
		sta DIGIT2
		jsr delay	
		lda buf3
		sta DIGIT3
		jsr delay
        bra d2
d1      lda buf4 ;display second value
		sta DIGIT0
		jsr delay
		lda buf5
		sta DIGIT1
		jsr delay
		lda buf6
		sta DIGIT2
		jsr delay	
		lda buf7
		sta DIGIT3
		jsr delay
d2		nop
		rts
;DISPLAY DELAY
delay	ldy #$f ;delay time for lcd's
return	LEAY -1,y
    	bne return
    	rts
;CLEAR BUFFERS, and registers		
clearbuf nop
			clr BUF0 ;clear buffers
			clr BUF1
			clr BUF2			
			clr BUF3
			clr BUF4
			clr BUF5
			clr BUF6			
			clr BUF7
			clr DIVIDEND       
			clr DIVIDEND+1
			clr DIVISOR       
			clr DIVISOR+1
			clr remainder       
			clr remainder+1	
			rts
			
;Subroutines - Load bcd input to "VALUE 1" registers 
ldV1LSB_1   lda buf0
            sta value1LSB ;load low nibble
        	rts
ldV1LSB_2   lda buf1 ;LSB LOAD first value
        	asla
        	asla
        	asla
        	asla ;shift left low nibble
        	ora buf0
        	sta value1LSB ; store two nibbles for lsb
        	rts
ldV1MSB_1   lda buf2
            sta value1MSB
        	rts        	
ldV1MSB_2   lda buf3 ;load low nibble
        	asla
        	asla
        	asla
        	asla ;shift left low nibble
        	ora buf2
        	sta value1MSB ; store two nibbles for MSB
        	rts
        	
;Subroutines - Load bcd input to "VALUE 2" registers 
ldV2LSB_1   lda buf4
            sta value2LSB ;load low nibble
        	rts
ldV2LSB_2   lda buf5 ;LSB LOAD first value
        	asla
        	asla
        	asla
        	asla ;shift left low nibble
        	ora buf4
        	sta value2LSB ; store two nibbles for lsb
        	rts
ldV2MSB_1   lda buf6
            sta value2MSB
        	rts        	
ldV2MSB_2   lda buf7 ;load low nibble
        	asla
        	asla
        	asla
        	asla ;shift left low nibble
        	ora buf6
        	sta value2MSB ; store two nibbles for MSB
        	rts	
			


;INPUT Handler , interupt controlled
            .ORG    $fc00 
			.ta $1c00
			
INCHAR:     NOP 
			ldx digpoint
            LDB     input ;key input in hex
			andb 	#$1f ;mask out bits 5,6,7
			cmpb #$0a ;10hex or higher?
		    bhs c3 ; branch to function load
			
			lda secv
			cmpa #$1 ;second value flag set ?
			beq c13
			
			lda keycount ;test first keypress
			cmpa #$00
            beq c5

			lda keycount ;test second keypress
			cmpa #$01
			beq c6

			lda keycount ;test third keypress
			cmpa #$02
			beq c7

			lda keycount ;test forth keypress
			cmpa #$03
			beq c8	

c13			lda keycount ;test first keypress
			cmpa #$00
            beq c9

			lda keycount ;test second keypress
			cmpa #$01
			beq c10

			lda keycount ;test third keypress
			cmpa #$02
			beq c11

			lda keycount ;test forth keypress
			cmpa #$03
			beq c12
			
c0          nop 
            INC     keycount
            LDA     keycount 
            CMPA    #$04 ; 4 key strokes?
            bne c2
C1          clr keycount
c2			nop
			bra c4
c3			stb 	func ;store function into compare buffer 
c4			nop
			RTi ; RETURN FROM INTERUPT	
			
; first value shift / load			
c5			nop
			stb buf0 
            jmp c0
c6			lda buf0 ;move digit0 to digit1
			sta buf1
			stb buf0 
            jmp c0
c7          lda buf1 ;shift values to left
            sta buf2
            lda buf0
            sta buf1
            stb buf0 
            jmp c0
c8          lda buf2 ;shift values to left
            sta buf3
            lda buf1
            sta buf2
            lda buf0
            sta buf1
            stb buf0 
            jmp c0	
;second value shift / load			
c9			nop
			stb buf4 
            jmp c0
c10			lda buf4 ;move digit0 to digit1
			sta buf5
			stb buf4 
            jmp c0
c11         lda buf5 ;shift values to left
            sta buf6
            lda buf4
            sta buf5
            stb buf4 
            jmp c0
c12         lda buf6 ;shift values to left
            sta buf7
            lda buf5
            sta buf6
            lda buf4
            sta buf5
            stb buf4 
            jmp c0


			
; VECTORS	
            .ORG    $fff8 
			.ta $1ff8
            .DW      $fc00 ;interupt vector	
            .DW      $fb00 ;SWI
            .DW      $fa00 ;NMI
            .DW      $e000 ;reset vector
            .END     
























