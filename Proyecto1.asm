//***************************************************************************
//Universidad del valle de Guatemala
//IE2023: Programación de Microcontroladores
//Autor: Luis Angel Ramirez Orózco
//Proyecto: Proyecto 1
//Hardware: ATMEGA328P
//Creado: 25/01/2024
//***************************************************************************
//***************************************************************************
//***************************************************************************

.def TIM=r16
.def SUB1=r17
.DEF SUB2=R18

.dseg 
.org 0x100 ;Direccion para almacenar en la SRAM
SEG: .BYTE 1 ;Segundos
TOPE_DIA : .BYTE 1 ;Fin de dias
ALARMA: .BYTE 1 ;Funcion o variable para la alarma
MINUTOS: .BYTE 1
HORAS: .BYTE 1
DIA: .BYTE 1
MES: .BYTE 1
MINUTO_HIGH: .BYTE 1
HORA_HIGH: .BYTE 1
ESTADO: .BYTE 1 ;Variable para el estado
LED: .BYTE 1 
ESTATUS: .BYTE 1 ;Parpadear Leds
CAMBIO: .BYTE 1 ;Funcion subir segundos
TIMER: .BYTE 1 ;Funcion para encender o apagar el TIMER de segundos
MODO1:  .BYTE 1 ; Funcion para determinar si se encenderan los primeros 2 diplays
MODO2:  .BYTE 1 ; Funcion para determinar si se encenderan los ultimos 2 displays
BIN_L: .BYTE 1 ;Numero
CONT_BCD0: .BYTE 1   ; BCD en Unidades
CONT_BCD1: .BYTE 1   ; BCD en decenas
CONT_BCD2: .BYTE 1   ; BCD en Unidades
CONT_BCD3: .BYTE 1   ; BCD en decenas
UNI_DIG0A: .BYTE 1   ; auxiliar en 7 seg de las UNIDADES
UNI_DIG1A: .BYTE 1   ; auxiliar en 7 seg de las DECENAS
UNI_DIG0: .BYTE 1   ; auxiliar en 7 seg de las UNIDADES
UNI_DIG1: .BYTE 1   ; auxiliar en 7 seg de las DECENAS
UNI_DIG2: .BYTE 1   ; auxiliar en 7 seg de las UNIDADES
UNI_DIG3: .BYTE 1   ; auxiliar en 7 seg de las DECENAS

UMIN: .BYTE 1
DMIN: .BYTE 1

UHOR: .BYTE 1
DHOR: .BYTE 1

UDIA: .BYTE 1
DDIA: .BYTE 1

UMES: .BYTE 1
DMES: .BYTE 1

UMIN_HIGH: .BYTE 1
DMIN_HIGH: .BYTE 1

UHOR_HIGH: .BYTE 1
DHOR_HIGH: .BYTE 1

DISPLAY7: .BYTE 1 
COUNT: .BYTE 1

 .cseg
 .org 0x00
 rjmp inicio
 .org 0x08
 rjmp BOTONES

  .ORG 0X16
 RJMP TIEMPO ; Interrupcion del TIMER1 que realiza los 500ms

 .ORG 0X1C
 RJMP BLINK ;Interrupciones para parpadeo de display




 inicio:
 LDI tim,255

 out DDRB,tim ;Purto B como salida
 OUT DDRD,TIM
 ldi tim,255
 out ddrd,TIM ;Puerto D para controlar los displays

 //**************************************************************************************//
 //*************************CONFIGURACION DEL CONVERSOR AD*******************************//
 //**************************************************************************************//

 LDI TIM,0B0011_1000 ;Puerto C para entrada botones y salida de LEDS
 OUT DDRC,TIM
 ;Activar Pull-up
 SBI PORTC,0
 SBI PORTC,1
 SBI PORTC,2

 //**************************************************************************************//
 //*************************CONFIGURACION DEL TIMER1*************************************//
 //**************************************************************************************//

  LDI R16,0B0000_0000  ;Configuracion en modo CTC
  STS TCCR1A,R16
  LDI R16,HIGH (15624) ;31249 se cargo el numero en dos registros
  STS OCR1AH,R16
  LDI R16,LOW(15624)       
  STS OCR1AL,R16     

  LDI R16,0B0000_1100 ;Empezar el TIMER con el preescalar 256



 //**************************************************************************************//
 //*************************CONFIGURACION DEL TIMER0*************************************//
 //**************************************************************************************//
  STS TCCR1B,R16 
  LDI R16,0B0000_0010 
  OUT TCCR0A,TIM
  LDI TIM, 255
  OUT OCR0A,TIM
  LDI TIM,0B0000_0101 ;Preescalar 1024
  OUT TCCR0B,TIM
  LDI TIM,2
  STS TIMSK0,TIM
  OUT TIFR0,TIM
 

  /******CONFIGURO LA INTERRUPCION DEL TIMER 1 POR COMPARACION CON A****/

 //**************************************************************************************//
 //****************CONFIGURACION DEL TIMER1 POR COMPARACION CON A************************//
 //**************************************************************************************//
  LDI R16,0B0000_0010
  STS TIMSK1,R16
  OUT TIFR1,R16  ;Se bajo la bandera




 //**************************************************************************************//
 //****************CONFIGURACION INTERRUPCIONES DE CAMBIO DE ESTADO**********************//
 //**************************************************************************************//
  LDI TIM,0B0000_0010 ;Puerto C
  STS PCICR,TIM
  LDI TIM,0B0000_0111
  STS PCMSK1,TIM
  CLR TIM
  STS DISPLAY7,TIM
  STS MODO1,TIM
  STS MODO2,TIM
  SEI ;Se habilitan las interrupciones
  CLR TIM
  STS ESTADO,TIM
  STS LED,TIM
  STS ESTATUS,TIM
  STS ALARMA,TIM


  LDI R16, 31
  STS DIA,R16
  LDI R16, 12
  STS MES,R16
  LDI R16,1
  STS MINUTO_HIGH,R16
  STS HORA_HIGH,R16
  CLR R16
  STS HORAS,R16
  STS MINUTOS,R16

  


LAZO: 
;Se comprueba si se encendera el reloj
LDS R5,MINUTOS
LDS R6,MINUTO_HIGH
LDS R7,HORAS
LDS R8,HORA_HIGH
CP R5,R6 ;Comparar minutos
BREQ VALIDAR
RJMP NEXT
VALIDAR:
CP R7,R8 ;Comparar horas
BREQ ALARMA_ON ;Se activara la alarma
RJMP NEXT
ALARMA_ON: 
LDS R17,ALARMA
CPI R17,1 
BREQ PRENDER_BUZZER
RJMP NEXT
PRENDER_BUZZER:
SBI PORTC,5 ;Prender buzzer


NEXT:


;Minutos
LDS TIM,MINUTOS
STS BIN_L,TIM
CALL BIN_BCD
CALL BCD_SEGMENTOS
LDS TIM,UNI_DIG0A
STS UMIN,TIM
LDS TIM,UNI_DIG1A
STS DMIN,TIM

;Horas
LDS TIM,HORAS
STS BIN_L,TIM
CALL BIN_BCD
CALL BCD_SEGMENTOS
LDS TIM,UNI_DIG0A
STS UHOR,TIM
LDS TIM,UNI_DIG1A
STS DHOR,TIM

;Dias
LDS TIM,DIA
STS BIN_L,TIM
CALL BIN_BCD
CALL BCD_SEGMENTOS
LDS TIM,UNI_DIG0A
STS UDIA,TIM
LDS TIM,UNI_DIG1A
STS DDIA,TIM

;Meses
LDS TIM,MES
STS BIN_L,TIM
CALL BIN_BCD
CALL BCD_SEGMENTOS
LDS TIM,UNI_DIG0A
STS UMES,TIM
LDS TIM,UNI_DIG1A
STS DMES,TIM

;Minutos_High
LDS TIM,MINUTO_HIGH
STS BIN_L,TIM
CALL BIN_BCD
CALL BCD_SEGMENTOS
LDS TIM,UNI_DIG0A
STS UMIN_HIGH,TIM
LDS TIM,UNI_DIG1A
STS DMIN_HIGH,TIM

;Horas_High
LDS TIM,HORA_HIGH
STS BIN_L,TIM
CALL BIN_BCD
CALL BCD_SEGMENTOS
LDS TIM,UNI_DIG0A
STS UHOR_HIGH,TIM
LDS TIM,UNI_DIG1A
STS DHOR_HIGH,TIM

LDS SUB1,ESTADO ;Leer el modo reloj
CPI SUB1,0
BREQ PMHORA
CPI SUB1,1
BREQ PMFECHA
CPI SUB1,2
BREQ PMALARMA
CPI SUB1,3
BREQ PMCHANGE ;Cambiar minutos con parpadeo
CPI SUB1,4
BREQ PHCHANGE ;Cambiar horas con parpadeo
CPI SUB1,5
BREQ PDCHANGE ;Cambiar dias con parpadeo
CPI SUB1,6
BREQ PMCHANGE ;Cambiar meses y parpadear
CPI SUB1,7
BREQ PMINUTOS_ON_CHANGE ;Cambiar minutos de horas
CPI SUB1,8
BREQ PHORAS_ON_CHANGE ;Cambiar meses y parpadear
RJMP LAZO


PMHORA:
RJMP MOSTRAR_HORA
PMFECHA:
RJMP MOSTRAR_FECHA
PMALARMA:
RJMP MOSTRAR_ALARMA
PMCHANGE:
RJMP MINUTOS_CHANGE
PHCHANGE:
RJMP HORAS_CHANGE
PDCHANGE:
RJMP DIAS_CHANGE
PMESES_CHANGE:
RJMP MESES_CHANGE
PMINUTOS_ON_CHANGE:
RJMP MINUTOS_ON_CHANGE
PHORAS_ON_CHANGE:
RJMP HORAS_ON_CHANGE
MOSTRAR_HORA:
CBI PORTC,4 ;Led fecha
LDI TIM,0
STS LED,TIM 
STS DISPLAY7,TIM
STS MODO1,TIM
STS MODO2,TIM
LDS TIM,UMIN
STS UNI_DIG0,TIM
LDS TIM,DMIN
STS UNI_DIG1,TIM
LDS TIM,UHOR
STS UNI_DIG2,TIM
LDS TIM,DHOR
STS UNI_DIG3,TIM
CALL BARRIDO 
RJMP LAZO

MOSTRAR_FECHA:
SBI PORTC,4 
LDI TIM,2
STS LED,TIM
LDI TIM,0
STS DISPLAY7,TIM
STS MODO1,TIM
STS MODO2,TIM
LDS TIM,UDIA
STS UNI_DIG0,TIM
LDS TIM,DDIA
STS UNI_DIG1,TIM
LDS TIM,UMES
STS UNI_DIG2,TIM
LDS TIM,DMES
STS UNI_DIG3,TIM
CALL BARRIDO 
RJMP LAZO

MOSTRAR_ALARMA:
CBI PORTC,4 ;Led fecha
LDI TIM,1
STS LED,TIM ;Dejar encendido Led
LDI TIM,0
STS DISPLAY7,TIM
STS MODO1,TIM
STS MODO2,TIM
LDS TIM,UMIN_HIGH
STS UNI_DIG0,TIM
LDS TIM,DMIN_HIGH
STS UNI_DIG1,TIM
LDS TIM,UHOR_HIGH
STS UNI_DIG2,TIM
LDS TIM,DHOR_HIGH
STS UNI_DIG3,TIM
CALL BARRIDO 
RJMP LAZO

MINUTOS_CHANGE: ;Cambiar minutos y parpadear
LDI TIM,0
STS LED,TIM 
LDI TIM,1
STS DISPLAY7,TIM
CLR TIM
STS MODO2,TIM
LDS TIM,UMIN
STS UNI_DIG0,TIM
LDS TIM,DMIN
STS UNI_DIG1,TIM
LDS TIM,UHOR
STS UNI_DIG2,TIM
LDS TIM,DHOR
STS UNI_DIG3,TIM
CALL BARRIDO 

RJMP LAZO

HORAS_CHANGE: ;Cambiar horas
CBI PORTC,4 ;Led fecha
LDI TIM,0
STS LED,TIM ;Parpadear
LDI TIM,2
STS DISPLAY7,TIM
CLR TIM
STS MODO1,TIM
LDS TIM,UMIN
STS UNI_DIG0,TIM
LDS TIM,DMIN
STS UNI_DIG1,TIM
LDS TIM,UHOR
STS UNI_DIG2,TIM
LDS TIM,DHOR
STS UNI_DIG3,TIM
CALL BARRIDO 
RJMP LAZO

DIAS_CHANGE: ;Se cambian los dias
SBI PORTC,4 ;Led fecha
LDI TIM,2
STS LED,TIM 
LDI TIM,1
STS DISPLAY7,TIM
CLR TIM
STS MODO2,TIM
LDS TIM,UDIA
STS UNI_DIG0,TIM
LDS TIM,DDIA
STS UNI_DIG1,TIM
LDS TIM,UMES
STS UNI_DIG2,TIM
LDS TIM,DMES
STS UNI_DIG3,TIM
CALL BARRIDO 
RJMP LAZO

MESES_CHANGE:
SBI PORTC,4 ;Led fecha
LDI TIM,2
STS LED,TIM 
LDI TIM,2
STS DISPLAY7,TIM
CLR TIM
STS MODO1,TIM
LDS TIM,UDIA
STS UNI_DIG0,TIM
LDS TIM,DDIA
STS UNI_DIG1,TIM
LDS TIM,UMES
STS UNI_DIG2,TIM
LDS TIM,DMES
STS UNI_DIG3,TIM
CALL BARRIDO 
RJMP LAZO

MINUTOS_ON_CHANGE: ;Cambiar minutos de alarma con parpadeo

CBI PORTC,4 ;Led fecha
LDI TIM,1
STS LED,TIM ;Setear Led
STS DISPLAY7,TIM
CLR TIM
STS MODO2,TIM
LDS TIM,UMIN_HIGH
STS UNI_DIG0,TIM
LDS TIM,DMIN_HIGH
STS UNI_DIG1,TIM
LDS TIM,UHOR_HIGH
STS UNI_DIG2,TIM
LDS TIM,DHOR_HIGH
STS UNI_DIG3,TIM
CALL BARRIDO 
RJMP LAZO

HORAS_ON_CHANGE: ;Cambio de horas de alarma
CBI PORTC,4 ;Led de fecha
LDI TIM,1 ;Set
STS LED,TIM ;Set Led
LDI TIM,2
STS DISPLAY7,TIM
CLR TIM
STS MODO1,TIM
LDS TIM,UMIN_HIGH
STS UNI_DIG0,TIM
LDS TIM, DMIN_HIGH
STS UNI_DIG1,TIM
LDS TIM,UHOR_HIGH
STS UNI_DIG2,TIM
LDS TIM,DHOR_HIGH
STS UNI_DIG3,TIM
CALL BARRIDO 
RJMP LAZO


 //**************************************************************************************//
 //*****************************RUTINA DE INTERRUPCIONES*********************************//
 //**************************************************************************************//

BOTONES: ;Interrupcion con cambio de estado
CALL DELAY  ;Evitar rebotes
CALL DELAY
IN TIM, PINC
ANDI TIM,0B0000_0111 
CPI TIM, 0B0000_0110 ;Presionar primer boton
BREQ P_B1
CPI TIM, 0B0000_0101 ;Presionar segundo boton
BREQ P_B2
CPI TIM, 0B0000_0011 ;Presionar tercer boton
BREQ P_B3
CPI TIM, 0B0000_0001 ;Presionar segundo y tercer boton
BREQ P_B2B3
RJMP SALIDA_B
P_B1:
RJMP B1
P_B2:
RJMP B2
P_B3:
RJMP B3
P_B2B3:
RJMP B2B3
B1: 
LDS SUB1,ESTADO
INC SUB1
CPI SUB1,1 
BREQ PCASO_1 ;Mostrar fecha
CPI SUB1,2
BREQ PCASO_2 ;Mostrar alarma
CPI SUB1,3
BREQ PCASO_3 ;Modificar minutos
CPI SUB1,4
BREQ PCASO_4 ;Modificar horas
CPI SUB1,5
BREQ PCASO_5 ;Modificar dias
CPI SUB1,6
BREQ PCASO_6 ;Modificar meses
CPI SUB1,7
BREQ PCASO_7 ;se modifica minutos en high
CPI SUB1,8
BREQ PCASO_8 ;Se modifica horas en high
CPI SUB1,9
BRPL PCASO_9 ;Resetea todo
STS ESTADO,SUB1

RJMP SALIDA_B
PCASO_1:
RJMP CASO_1
PCASO_2:
RJMP CASO_2
PCASO_3:
RJMP CASO_3
PCASO_4:
RJMP CASO_4
PCASO_5:
RJMP CASO_5
PCASO_6:
RJMP CASO_6
PCASO_7:
RJMP CASO_7
PCASO_8:
RJMP CASO_8
PCASO_9:
RJMP CASO_9

B2: 
LDS SUB1,ESTADO 
CPI SUB1,3 ;Subir minutos
BREQ PMIN_UP
CPI SUB1,4 ;Subir horas
BREQ PHOR_UP
CPI SUB1,5 ;Subir dias
BREQ PDIAS_UP
CPI SUB1,6
BREQ PMESES_UP ;Subir meses
CPI SUB1,7
BREQ PMIN_ON_UP ;Subir minutos alarma
CPI SUB1,8
BREQ PHOR_ON_UP ;Subir horas alarma
RJMP SALIDA_B

PMIN_UP:
RJMP MIN_UP
PHOR_UP:
RJMP HOR_UP
PDIAS_UP:
RJMP DIAS_UP
PMESES_UP:
RJMP MESES_UP
PMIN_ON_UP:
RJMP MIN_ON_UP
PHOR_ON_UP:
RJMP HOR_ON_UP

MIN_UP:

LDS SUB1,MINUTOS
INC SUB1
STS MINUTOS,SUB1
CPI SUB1,60 
BRPL MIN_CERO
STS MINUTOS,SUB1
RJMP SALIDA_B
MIN_CERO:
CLR SUB1
STS MINUTOS,SUB1
RJMP SALIDA_B

HOR_UP:
LDS SUB1,HORAS
INC SUB1
CPI SUB1,24 
BRPL HOR_CERO
STS HORAS,SUB1
RJMP SALIDA_B
STS HORAS,SUB1
HOR_CERO:
CLR SUB1
STS HORAS,SUB1
RJMP SALIDA_B

DIAS_UP:
LDS R26,MES
CPI R26,2 
BREQ MES_FEBRERO
CPI R26,1
BREQ MES_31
CPI R26,3
BREQ MES_31
CPI R26,5
BREQ MES_31
CPI R26,7
BREQ MES_31
CPI R26,8
BREQ MES_31
CPI R26,12
BREQ MES_31
RJMP MES_30
MES_FEBRERO:
LDI R28,29
STS TOPE_DIA,R28
RJMP SEGUIR_1
MES_31:
LDI R28,32
STS TOPE_DIA,R28
RJMP SEGUIR_1
MES_30:
LDI R28,31
STS TOPE_DIA,R28
RJMP SEGUIR_1
SEGUIR_1:
LDS SUB1,DIA
INC SUB1
LDS R31,TOPE_DIA
CP SUB1,R31 
BRPL DIA_CERO
STS DIA,SUB1
RJMP SALIDA_B
DIA_CERO:
LDI SUB1,1
STS DIA,SUB1
RJMP SALIDA_B

MESES_UP: ;Subir los meses
LDS SUB1,MES
INC SUB1
CPI SUB1,13 
BRPL MESES_CERO
STS MES,SUB1
RJMP SALIDA_B
MESES_CERO:
LDI SUB1,1
STS MES,SUB1
RJMP SALIDA_B

MIN_ON_UP: ;Subir minutos alarma
LDI R28,1
STS ALARMA,R28
LDS SUB1,MINUTO_HIGH
INC SUB1
CPI SUB1,60 
BREQ MINUTO_ON_CERO
STS MINUTO_HIGH,SUB1
RJMP SALIDA_B
MINUTO_ON_CERO:
CLR SUB1
STS MINUTO_HIGH,SUB1
RJMP SALIDA_B

HOR_ON_UP: ;Subir horas alarma
LDI R28,1
STS ALARMA,R28
LDS SUB1,HORA_HIGH
INC SUB1
CPI SUB1,24 
BREQ HORA_ON_CERO
STS HORA_HIGH,SUB1
RJMP SALIDA_B
HORA_ON_CERO:
CLR SUB1
STS HORA_HIGH,SUB1
RJMP SALIDA_B


B3: 
LDS SUB1,ESTADO 
CPI SUB1,3 ;Bajar minutos
BREQ PMIN_BAJO
CPI SUB1,4 ;Bajar horas
BREQ PHOR_BAJO
CPI SUB1,5 ;Bajar dias
BREQ PDIAS_BAJO
CPI SUB1,6
BREQ PMESES_BAJO ;Bajar meses
CPI SUB1,7
BREQ PMIN_ON_BAJO ;Bajar minutos alarma
CPI SUB1,8
BREQ PHOR_ON_BAJO ;Bajar horas alarma

RJMP SALIDA_B
PMIN_BAJO:
RJMP MIN_BAJO
PHOR_BAJO:
RJMP HOR_BAJO
PDIAS_BAJO:
RJMP DIAS_BAJO
PMESES_BAJO:
RJMP MESES_BAJO
PMIN_ON_BAJO:
RJMP MIN_ON_BAJO
PHOR_ON_BAJO:
RJMP HOR_ON_BAJO


MIN_BAJO:
LDS SUB1,MINUTOS
DEC SUB1
CPI SUB1,0 
BRLT MINUTO_FULL
STS MINUTOS,SUB1
RJMP SALIDA_B
MINUTO_FULL:
LDI SUB1,59
STS MINUTOS,SUB1

RJMP SALIDA_B

HOR_BAJO:
LDS SUB1,HORAS
DEC SUB1
CPI SUB1,0 
BRLT HOR_FULL
STS HORAS,SUB1
RJMP SALIDA_B
HOR_FULL:
LDI SUB1,23
STS HORAS,SUB1
RJMP SALIDA_B

DIAS_BAJO:
LDS R26,MES
CPI R26,2 
BREQ BMES_FEBRERO
CPI R26,1
BREQ BMES_31
CPI R26,3
BREQ BMES_31
CPI R26,5
BREQ BMES_31
CPI R26,7
BREQ BMES_31
CPI R26,8
BREQ BMES_31
CPI R26,12
BREQ BMES_31
RJMP BMES_30
BMES_FEBRERO:
LDI R28,28
STS TOPE_DIA,R28
RJMP SEGUIR_2
BMES_31:
LDI R28,31
STS TOPE_DIA,R28
RJMP SEGUIR_2
BMES_30:
LDI R28,30
STS TOPE_DIA,R28
RJMP SEGUIR_2
SEGUIR_2:

LDS SUB1,DIA
DEC SUB1
CPI SUB1,1 
BRLT DIA_FULL
STS DIA,SUB1
RJMP SALIDA_B
DIA_FULL:
LDS SUB1,TOPE_DIA
STS DIA,SUB1
RJMP SALIDA_B

MESES_BAJO:;Subir los meses
LDS SUB1,MES
DEC SUB1
CPI SUB1,1 
BRLT MESES_FULL
STS MES,SUB1
RJMP SALIDA_B
MESES_FULL:
LDI SUB1,12
STS MES,SUB1
RJMP SALIDA_B

MIN_ON_BAJO: ;Subir minutos alarma
LDI R28,1
STS ALARMA,R28
LDS SUB1,MINUTO_HIGH
DEC SUB1
CPI SUB1,0 
BRLT MINUTO_ON_CERO_FULL
STS MINUTO_HIGH,SUB1
RJMP SALIDA_B
MINUTO_ON_CERO_FULL:
LDI SUB1,59
STS MINUTO_HIGH,SUB1
RJMP SALIDA_B

HOR_ON_BAJO: ;Subir horas alarma
LDI R28,1
STS ALARMA,R28
LDS SUB1,HORA_HIGH
DEC SUB1
CPI SUB1,0
BRLT HORA_ON_CERO_FULL
STS HORA_HIGH,SUB1
RJMP SALIDA_B
HORA_ON_CERO_FULL:
LDI SUB1,23
STS HORA_HIGH,SUB1
RJMP SALIDA_B


B2B3: ;Apagar alarma
CLR R28
STS ALARMA,R28
CBI PORTC,5
RJMP SALIDA_B
CASO_1:
STS ESTADO,SUB1
RJMP SALIDA_B
CASO_2:
STS ESTADO,SUB1
RJMP SALIDA_B
CASO_3:
STS ESTADO,SUB1
RJMP SALIDA_B
CASO_4:
STS ESTADO,SUB1
RJMP SALIDA_B
CASO_5:
STS ESTADO,SUB1
RJMP SALIDA_B
CASO_6:
STS ESTADO,SUB1
RJMP SALIDA_B
CASO_7:
STS ESTADO,SUB1
RJMP SALIDA_B
CASO_8:
STS ESTADO,SUB1
RJMP SALIDA_B
CASO_9:
CLR TIM
STS ESTADO,TIM
RJMP SALIDA_B











SALIDA_B:
RETI
BIN_BCD: ;Rutina para convertir todos los numeros A BCD

LDS R19,BIN_L
MOV R4,R19
CLR R17
DECENAS:
SUBI R19,10
BRCS PREUNIDADES 
INC R17 ;Incrementar numero en decenas
RJMP DECENAS

PREUNIDADES:  ;Almacenar numero en decenas
STS CONT_BCD1,R17 
LDI R16,10
MUL R17,R16
SUB R4,R0

STS CONT_BCD0,R4  ;Almacenos unidades en espacio

RET
BCD_SEGMENTOS:
PUSH R16
PUSH R17

LDS R16,CONT_BCD0  

ldi		zh,high(tabla<<1)    ; Apunto a la direccion alta de la tabla
ldi		zl,low(tabla<<1)	; Apunto a la direccion baja de la tabal
add		zl,R16		; Ubico el numero buscado		
clr		R16			; Dejo vacio el registro			
lpm		R16,z		; copio el valor de la tabla en el registro
STS UNI_DIG0A,R16


LDS R16,CONT_BCD1 

ldi		zh,high(tabla<<1)    ; Apunto a la direccion alta de la tabla
ldi		zl,low(tabla<<1)	; Apunto a la direccion baja de la tabal
add		zl,R16		;Ubico el numero buscado		
clr		R16			;Dejo vacio el registro			
lpm		R16,z		;Copio el valor de la tabla en el registro

STS UNI_DIG1A,R16
POP R17
POP R16
RET
 //**************************************************************************************//
 //******************************BARRIDO DE DISPLAYS*************************************//
 //**************************************************************************************//

BARRIDO:
PUSH R16
PUSH R17

LDS R20, MODO1 ;Comparar si se activan los primeros dos displays
CPI R20,255
BREQ SIGUIENTE
NORMAL_1: 


LDS R16,UNI_DIG0 
OUT PORTB,R16 ;Mostrar en los segmentos
ANDI R16,0B0100_0000
ORI R16, 0B0011_1000 ;Activar primer display
OUT PORTD,R16
CALL DELAY
;Apagar todos los displays
ORI R16, 0B0011_1100 ;Apagar primer display
OUT PORTD,R16


LDS R16,UNI_DIG1 
OUT PORTB,R16 ;Mostrar en los segmentos
ANDI R16,0B0100_0000
ORI R16, 0B0011_0100 ;Activar segundo display
OUT PORTD,R16
CALL DELAY
;Apagar todos los displays
ORI R16, 0B0011_1100 ;Apagar el segundo display
OUT PORTD,R16

SIGUIENTE:
LDS R20, MODO2 ;Comparar
CPI R20,255
BREQ EXIT_A
;Enviar centenas

LDS R16,UNI_DIG2 
OUT PORTB,R16 ;Mostrar los segmentos
ANDI R16,0B0100_0000
ORI R16, 0B0010_1100 ;Activar tercer display 
OUT PORTD,R16
CALL DELAY
;Apagar todo los displays
ORI R16, 0B0011_1100 ;Apagar tercer display
OUT PORTD,R16
;Enviar miles

LDS R16,UNI_DIG3 
OUT PORTB,R16 ;Mostrar los segmentos
ANDI R16,0B0100_0000
ORI R16, 0B0001_1100 ;Activar cuarto display 
OUT PORTD,R16
CALL DELAY
;Apagar todos los diplays
ORI R16, 0B0011_1100 ;Apagar el cuarto display
OUT PORTD,R16

EXIT_A:
POP  R17
POP R16
ret



TIEMPO:  ;Interrupcion que salta cada 500ms
LDS R23,LED ;Parpadeo
CPI R23,0 
BREQ TOGLE ;Modo reloj
CPI R23,1
BREQ SETEADO ;Modo Alarma
CPI R23,2
BREQ APAGADO ;Modo fecha
RJMP CONTINUE
TOGLE:
LDS R24,ESTATUS
COM R24
STS ESTATUS,R24
CPI R24,255 ;Encender led
BREQ LED_ON
RJMP LED_OFF
LED_ON:
SBI PORTC,3
RJMP CONTINUE
LED_OFF:
CBI PORTC,3

RJMP CONTINUE
SETEADO:
SBI PORTC,3
RJMP CONTINUE

APAGADO:
CBI PORTC,3
RJMP CONTINUE






CONTINUE:
LDS SUB1, CAMBIO ;Determinar si cambio a 2
INC SUB1
CPI SUB1,2
BREQ UP_S
STS CAMBIO,SUB1
RJMP EXIT
UP_S: ;Incrementar los segundos
CLR SUB1
STS CAMBIO,SUB1
LDS TIM,SEG
INC TIM
CPI TIM,60 ;si es igual a 60 se enciende
BREQ ENCERAR_SEG ;Enciende y sube
STS SEG,TIM ;Almacenar
RJMP EXIT
ENCERAR_SEG:
CLR SUB1
STS SEG,SUB1
LDS TIM,MINUTOS ;Leer minutos
INC TIM
CPI TIM,60 ;Si es igual a 60
BREQ ENCERAR_MIN
STS MINUTOS,TIM
RJMP EXIT
ENCERAR_MIN:
CLR SUB1
STS MINUTOS,SUB1
LDS TIM,HORAS
INC TIM
STS HORAS,TIM
CPI TIM,24 ;Si es igual a 23
BREQ ENCERAR_HORA
RJMP EXIT
ENCERAR_HORA:
CLR SUB1
STS MINUTOS,SUB1
STS HORAS,SUB1


EXIT:
RETI


BLINK:

LDS TIM,COUNT
INC TIM
CPI TIM,10
BREQ ALTO
RJMP SALIDA_D
ALTO: ;Subir contador en 1
CLR TIM
STS COUNT,TIM

LDS R20,DISPLAY7
CPI R20, 0
BREQ NINGUNA  ;No parpadear
CPI R20,1
BREQ PRIMERA ;Parpadear primeros
CPI R20,2
BREQ SEGUNDA ;Parpadear segundos
RJMP SALIDA_D
NINGUNA:
RJMP SALIDA_D
PRIMERA:
LDS SUB1,MODO1
COM SUB1
STS MODO1,SUB1
RJMP SALIDA_D
SEGUNDA:
LDS SUB1,MODO2
COM SUB1
STS MODO2,SUB1
SALIDA_D:
STS COUNT,TIM

RETI
;Retardo de (1+1+1+2)*AXBXC
DELAY:
CLR r20
CLR r21
CLR r22
LDI  R20,10

L1:
LDI   R21,10 
	 
L2:
LDI  R22,25
L3:

DEC R22
NOP
NOP

BRNE L3
DEC R21
BRNE L2
DEC R20
BRNE L1

RET

//**************************************************************************************//
//******************************TABLA DE 7 SEGMENTOS************************************//
//**************************************************************************************//
tabla: ;gfedcba gfedcba
.db 0b00111111,0b0000_0110 ;0,1
.db 0b01011011,0b0100_1111 ;2,3
.db 0b01100110,0b0110_1101 ;4,5
.db 0b01111101,0b0000_0111 ;6,7
.db 0b01111111,0b0110_1111 ;8,9










