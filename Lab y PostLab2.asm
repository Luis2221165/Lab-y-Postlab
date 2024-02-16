
//***************************************************************************
//Universidad del valle de Guatemala
//IE2023: Programación de Microcontroladores
//Autor: Luis Angel Ramirez Orózco
//Proyecto: Prelab
//Hardware: ATMEGA328P
//Creado: 25/01/2024
//***************************************************************************

//***************************************************************************
//Encabezado
//***************************************************************************
 
.INCLUDE "M328PDEF.inc"
.cseg 
.org 0x00


//***************************************************************************
//Configuración de la Pila
//***************************************************************************
LDI R16, LOW(RAMEND)
OUT SPL, R16
LDI R17, HIGH(RAMEND)
OUT SPH, R17

//***************************************************************************
//TABLA DE VALORES
//***************************************************************************
			TABLA7SEG: .DB 0B01000000, 0B01111001, 0b00100100, 0b00110000, 0b00011001, 0b0010010, 0b0000010, 0b01111000, 0b00000000, 0b00010000, 0b00001000, 0b00000011, 0b001000110, 0b00100001, 0b00000110, 0b00001110
//0            1           2         3             4          5           6          7           8         9             10           11        12           13           14          15
			;TABLA7SEG: .DB 0B01000000, 0B01111001, 0b00100100, 0b00110000, 0b00011001, 0b0010010, 0b0000010, 0b01111000, 0b00000000, 0b00010000, 0b00001000, 0b00000011, 0b001000110, 0b00100001, 0b00000110, 0b00001110
							//0 				
//***************************************************************************

SETUP:
LDI R16, 0XFF
	OUT DDRD, R16//Salida 7 seg
	OUT DDRB, R16	
	OUT PORTC, R16
	ldi R16, 0
	OUT DDRC, R16
	
	LDI R20, 0
	sts UCSR0B,  R20
	LDI ZH, HIGH(TABLA7SEG<<1)
	LDI ZL, LOW(TABLA7SEG<<1)
Timer0:
	LDI R16, (1<<CS02) |  (1<<CS00)
	OUT TCCR0B, R16
	
	LDI R16, 190		;CARGAR EL VALOR DE DESBORDAMIENTO
	OUT TCNT0, R16			;Cargar el valor incial 
	RJMP LecturadeBoton

LecturadeBoton:
IN R24, PINC
	ANDI R24, 0b00001100
	CPI R24, 4
	breq Incremento7seg

	CPI R24, 8
	breq Decremento7seg

	CPI R24, 0
	BREQ EncenLuc


EncenLuc:
	LDI ZH, HIGH(TABLA7SEG<<1)
	LDI ZL, LOW(TABLA7SEG<<1)
	ADD	ZL, R23
	ldi R18, 0
	LDI R19, 0

	LPM R18, Z
	OUT PORTD, R18

	IN R16, TIFR0
	CPI R16, (1<<TOV0)
	BRNE LecturadeBoton		;Si no esta seteada, continuar esperando 
LDI R16, 190
	OUT TCNT0, R16
	SBI TIFR0, TOV0
	INC R25
	CPI R25, 10
	BRNE EncenLuc
	;clr	r25
	
ContT:
	MOV R19, R22
	ANDI R22, 0b00001111
	CPI R23, 0
	BREQ Salto3
	ANDI R19, 0b00100000
	CPI R19, 0b00100000
	BRNE LedO
	CP R22, R23
	BRNE Salto5
	LDI R22, 0b00000000
	RJMP Vres
Ledo:
	CP R22, R23
	BRNE Salto3
	ldi R22,0b00100000
	RJMP Vres
Salto5:
	LDI R19, 0b00100000
	or R22, R19
Salto3:
	INC R22


Vres:
	OUT PORTB, R22
	RJMP LecturadeBoton
Incremento7seg:
	; Antes de realizar cambios en el 7 segmentos
	ldi R16, (0 << CS02) | (0 << CS01) | (0 << CS00)  ; Desactivar temporizador
	out TCCR0B, R16
	cpi R20, 0x0F
    BREQ Salto
	INC R20
Salto:
	rcall delay
	MOV R23, R20
	;ADD	ZL, R23
	RJMP Timer0
//*************************************
Decremento7seg:
	; Antes de realizar cambios en el 7 segmentos
	ldi R16, (0 << CS02) | (0 << CS01) | (0 << CS00)  ; Desactivar temporizador
	out TCCR0B, R16
	cpi R20, 0x00
    BREQ LecturadeBoton
	DEC R20
	rcall delay
	MOV R23, R20
	ADD	ZL, R23
	RJMP Timer0
stop:
	RJMP LecturadeBoton

delay:
	LDI R17, 155

ANT0:
	LDI R18, 155
ANT2:
	NOP
	BRNE ANT2
	DEC R18
	DEC R17
	BRNE ANT0
//***************************************************************************
