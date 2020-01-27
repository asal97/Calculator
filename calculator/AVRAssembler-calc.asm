/**
 Calculator.asm

 Created: 01/11/1397 09:24:21 ?.?
 Author : Cloner
**/

.include "m32def.inc"

.org     $0200
.db      $EE, $ED, $EB, $E7, $DE, $DD, $DB, $D7, $BE, $BD, $BB, $B7, $7E, $7D, $7B, $77 ;keyboard value
.org     0
rjmp     main
.org     $0010

main:
	sei  ; Intrupts Enable
	ldi R16, $F0
	out ddrb, r16   ; set portB (in/out) (Keyboard in-out)
	ldi r16, $FF
	out ddrd, r16   ; PortD (Out) ; 8bit (4bit 3rd 7seg - 4bit 4th 7Seg)
	out ddrc, r16; PortC (Out) ; 8bit (4bit 1st 7Seg - 4bit 2nd 7Seg)
	ldi R25, 0 ; Set Current state 

FirstState: ;first state
	ldi R18, $EF 
	clr R17

Loop1:;KeyBoard

	out  portB, R18 ; Clear first row
	in   R19, pinB ; PinB 
	andi R19, $0F ; input value(4 lowers bit)
	cpi  R19, $0F
	brne correctInput ; R18=Row (rrrr ....) , R19=Column	(.... cccc)
	inc  R17
	cpi  R17, 4 ; Scanned rows
	breq FirstState
	rol  r18 ; Not found, Scan next row
	rjmp Loop1

correctInput: 
	clr  R17
	andi R19, $0f
	andi R18, $f0
	or   R18, R19 ; R18 -> Row + Column

	ldi  R31, $04 ; go too keypad table
	ldi  R30, $00
	
 ; Search all the memory cells, from $0400 to $0400 + 16
searchKey:	lpm  R0, Z+ 
			cp   R0,  R18
			breq FoundKey
			inc  R17
			cpi  R17, 16
			clr  R20
			rjmp searchKey

FoundKey:	mov R20, R17 ; Code found, move it to CurrentKey register
			call EnterKey ; do function
			call Update_7Segment ; Update 7-segment
	
Wait:		in   R19, pinB ; Wait until the user get his/her finger out of buttons
			andi R19, $0f   
			cpi  R19, $0f
			brne Wait
			rjmp FirstState

	






EnterKey:	 cpi R20, 13 ; '0'is 13th element of keyboard table.
			 breq Enter0   
			 cpi R20, 8 ; '1'is 8th element of keyboard table.
			 breq Enter1
			 cpi R20, 9 ; '2'is 9th element of keyboard table.
			 breq Enter2
			 cpi R20, 10 ; '3'is 10th element of keyboard table.
			 breq Enter3
			 cpi R20, 4 ; '4'is 4th element of keyboard table.
			 breq Enter4
			 cpi R20, 5 ; '5'is 5th element of keyboard table.
			 breq Enter5
			 cpi R20, 6 ; '6'is 6th element of keyboard table.
			 breq Enter6
			 cpi R20, 0 ; '7'is 0th element of keyboard table.
			 breq Enter7
			 cpi R20, 1 ; '8'is 1th element of keyboard table.
			 breq Enter8
			 cpi R20, 2 ; '9'is 2th element of keyboard table.
			 breq Enter9
			 cpi R20, 12 ; 'C'is 12th element of keyboard table.
			 breq EnterC
			 cpi R20, 7 ; '*'is 7th element of keyboard table.
			 breq EnterMul
			 cpi R20, 15 ; '+'is 15th element of keyboard table.
			 breq EnterSum
			 cpi R20, 3 ; '/'is 3th element of keyboard table.
			 breq EnterDiv
			 cpi R20, 11 ; '-'is 11th element of keyboard table.
			 breq EnterSub
			 cpi R20, 14  ; '='is 14th element of keyboard table.
			 breq EnterEqu

	Enter0:
		clr R16
		mov R15, R16
		rjmp ProcessMakerForNumbers

	Enter1:
		ldi R16, 1
		mov R15, R16
		rjmp ProcessMakerForNumbers

	Enter2:
		ldi R16, 2
		mov R15, R16
		rjmp ProcessMakerForNumbers

	Enter3:
		ldi R16, 3
		mov R15, r16
		rjmp ProcessMakerForNumbers

	Enter4:
		ldi R16, 4
		mov R15, R16
		rjmp ProcessMakerForNumbers

	Enter5:
		ldi R16, 5
		mov R15, R16
		rjmp ProcessMakerForNumbers

	Enter6:
		ldi R16, 6
		mov R15, R16
		rjmp ProcessMakerForNumbers

	Enter7:
		ldi R16, 7
		mov R15, R16
		rjmp ProcessMakerForNumbers

	Enter8:
		ldi R16, 8
		mov R15, r16
		rjmp ProcessMakerForNumbers

	Enter9:
		ldi R16, 9
		mov R15, r16
		rjmp ProcessMakerForNumbers

	EnterC: clr R16 ;All registers are '0'
			clr R21   
			clr R22
			clr R23
			clr R24  
			clr R25    
			clr R29
			out portA, R29
			out portC, R16 
			out portD, R16
			ret
	
	EnterMul:	ldi R16, 6
				mov R13, R16
				rjmp ChooseOperator

	EnterSum:	ldi R16, 5
				mov R13, R16
				rjmp ChooseOperator

	EnterDiv:	ldi R16, 8
				mov R13, R16
				rjmp ChooseOperator

	EnterSub:	ldi R16, 7
				mov R13, R16
				rjmp ChooseOperator

	ChooseOperator:		mov R14, R13
						ldi R16, 2 ; set '='
						mov R25, R16
						ret
	
	EnterEqu:		cpi R25, 3
					breq calculate
					cpi R25, 2
					breq calculate
					ret

	calculate:	mov R16, R14  ;get function
				cpi R16, 6
				breq Multi
				cpi R16, 5
				breq Sum
				cpi R16, 8
				breq Divide
				cpi R16, 7
				breq Subscribe

		Multi:	mul R21, R22 ; First Number '*' Second Number
				mov R24, R1
				mov R23, R0
				ldi R25, 4
				ret
			
		Sum:	mov r16, R21 ; First Number '+' Second Number
				add r16, R22
				mov R23, r16
				ldi R25, 4
				ret

		Divide:		clr R17	; First Number '/' Second Number
					cpi  R22, 0
					breq exeption
					mov R16, R21
					devFinder:
						cp   R16 , R22
						brlo devFound
						sub  R16, R22
						inc  R17
						rjmp devFinder
					devFound:
						mov R23, R17
						ldi R25, 4
						ret
					exeption:
						ldi R29, $FF
						out ddrA,R29
						out portA,R29
						ret

		Subscribe:	mov R16, R21 ; First Number '-' Second Number
					sub R16, R22
					mov R23, R16
					ldi R25, 4
					ret



	ProcessMakerForNumbers:
		cpi R25, 0
		breq firstNumberProcessing
		cpi R25, 2
		breq secondNumberProcessing	
		ret

		firstNumberProcessing: ;get first number
			cpi R21, 10  ; If number > 10
			brsh firstStateOperand ; change state 
			ldi R16, 10
			mul R21, R16 ; FirstNumber = FirstNumber * 10
			mov R21, R0
			mov R16, R15
			add R21, R16   ; FirstNumber = FirstNumber * 10 + (Pressed Key Value)
			cpi R21, 10
			brsh firstStateOperand
			ret

		secondNumberProcessing: ; Exactly as same above, but for Second number
			cpi R22, 10
			brsh NextStateOperand
			ldi r16, 10
			mul R22, r16 ; r0 <-- r16 * r22
			mov R22, R0
			mov R16, R15
			add R22, R16
			cpi R22, 10
			brsh NextStateOperand
			ret
		firstStateOperand:  
			ldi R25, 1 ;opperand
			ret
		NextStateOperand: 
			ldi R25, 3 ;Wait for equal
			ret







Update_7Segment:	cpi R25, 0	; update 7-segment
					breq FirstNumberLED
					cpi R25, 1
					breq FirstNumberLED
					cpi R25, 2
					breq SecondNumberLED
					cpi R25, 3
					breq SecondNumberLED
					cpi R25, 4
					breq ShowResult
	

	FirstNumberLED:	mov R16, R21
					clr r17
			Ten_1:	cpi r16 , 10
					brlo showNumber_1
					subi R16, 10
					inc  R17
					rjmp Ten_1; Preview First Number on 7-segment	
			showNumber_1:	swap r17
							or   r17, r16
							out portc, r17
							ret

			SecondNumberLED:	mov R16, R22 ; Preview Second Number on 7-segment
								clr R17
						Ten_2:	cpi R16 , 10
								brlo showNumber_2
								subi R16, 10
								inc  R17
								rjmp Ten_2
				showNumber_2:	swap R17
								or   R17, R16
								out portC, R17
								ret
						

	ShowResult:		mov R16, R14 
					cpi R16, 5
					breq NoAction
					cpi R16, 6
					breq Action
					cpi R16, 7
					breq NoAction
					cpi R16, 8
					breq NoAction
		
		NoAction:	mov R26, R23
					clr R27
					clr R28
			
			HundredSeprator:	cpi  R26, 100
								brlo TenSeprator
								subi R26, 100
								inc  R28
								rjmp HundredSeprator
				
				TenSeprator:	cpi  R26, 10
								brlo showNumber_3
								subi R26, 10
								inc  R27
								rjmp TenSeprator
				
				showNumber_3:	swap R27
								or   R27, R26
								out portC, R27
								out portD, R28
								ret
				
		Action:	call BtoB
				out portC, R4
				out portD, R5
				ret
			









BtoB:;BINARY TO BCD
	clr r31
	clr r30
	mov R16, R23
	mov R17, R24
	ser	R31
	mov	R6,R31

	AAA:
		inc		R6
		subi	R16,low(10000)
		sbci	R17,high(10000)
		brcc	AAA
		subi	R16,low(-10000)
		sbci	R17,high(-10000)
		ldi		R30,(256-16)
	BBB:
		subi	R30,(-16)
		subi	R16,low(1000)
		sbci	R17,high(1000)
		brcc	BBB
		subi	R16,low(-1000)
		sbci	R17,high(-1000)
		mov		R5,R31
	CCC:
		inc		R5
		subi	R16,low(100)
		sbci	R17,high(100)
		brcc	CCC
		subi	R16,low(-100)
		or		R5,R30
		ldi		R30,(256-16)
	DDD:
		subi	R30,(-16)
		subi	R16,10
		brcc	DDD
		subi	R16,-10
		mov		R4,R30
		or		R4,R16
	ret