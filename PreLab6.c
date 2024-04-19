//***************************************************************************
//Universidad del valle de Guatemala
//IE2023: Programación de Microcontroladores
//Autor: Luis Angel Ramirez Orózco
//Proyecto: PreLab6
//Hardware: ATMEGA328P
//Creado: 25/01/2024
//***************************************************************************
//***************************************************************************
//***************************************************************************

#define F_CPU 16000000
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>

void initUART9600(void);
void writeUART(char Caracter);
void writeStringUART(const char *str);
volatile uint8_t bufferTX;

int main(void) {
    initUART9600();
    writeStringUART("Mi primer texto :)\n");

    while (1) {
        // El programa principal no realiza ninguna acción adicional
    }
}

void initUART9600() {
    // Paso 1: RX como entrada y TX como salida
    DDRD &= ~(1 << DDD0);
    DDRD |= (1 << DDD1);

    // Paso 2: Configurar UCSR0A
    UCSR0A = 0;

    // Paso 3: Configurar UCSR0B: habilitamos ISR de recepción, habilitamos Rx y Tx
    UCSR0B = 0;
    UCSR0B |= (1 << RXCIE0) | (1 << RXEN0) | (1 << TXEN0);

    // Paso 4: Configurar UCSR0C: Asíncrono, Paridad: None, bit de STOP
    UCSR0C = 0;
    UCSR0C |= (1 << UCSZ01) | (1 << UCSZ00);

    // Paso 5: Configurar velocidad de Baudrate: 9600
    UBRR0 = 103;
}

void writeUART(char Caracter) {
    while (!(UCSR0A & (1 << UDRE0)));
    UDR0 = Caracter;
}

void writeStringUART(const char *str) {
    while (*str) {
        writeUART(*str++);
    }
}

ISR(USART_RX_vect) {
    bufferTX = UDR0;
    while (!(UCSR0A & (1 << UDRE0)));
    UDR0 = bufferTX;
}
