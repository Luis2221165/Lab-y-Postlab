//***************************************************************************
//Universidad del valle de Guatemala
//IE2023: Programación de Microcontroladores
//Autor: Luis Angel Ramirez Orózco
//Proyecto: PreLab6
//Hardware: ATMEGA328P
//Creado: 26/04/2024
//***************************************************************************
//***************************************************************************
//***************************************************************************


#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include <stdint.h>

// Variables globales
int menuActivo = 0; // Variable para controlar la activación del menú
int datoADC;        // Variable para almacenar el valor del ADC

// Prototipos de funciones
void iniciarADC(void); // Función para inicializar el ADC
void iniciarUART9600(void); // Función para inicializar UART a 9600 baudios
void escribirUART(char Caracter); // Función para enviar un carácter por UART
void escribirTextoUART(const char *Texto); // Función para enviar una cadena de caracteres por UART

// Constantes para representación de números ASCII
const char numerosASCII[10] = {'0','1','2','3','4','5','6','7','8','9'};

int main(void)
{
	DDRB = 0b00111111;  // Salida hacia LEDs  PB0 a PB5
	DDRD |= 0b11000000; // Configura PD6 y PD7 como salidas

	iniciarADC(); // Inicializa el ADC
	iniciarUART9600(); // Inicializa UART a 9600 baudios

	sei(); // Habilita las interrupciones globales

	while (1)
	{
		// Leer el valor del ADC
		ADCSRA |= (1 << ADSC);

		// Menú principal
		if(menuActivo == 0){
			// Muestra el menú principal por UART
			escribirTextoUART("\n\r************** Bienvenido **************\n\r");
			escribirTextoUART("1. Leer valor del potenciómetro\n\r");
			escribirTextoUART("2. Enviar caracter ASCII\n\r");
			menuActivo = 1;
		}

		// Procesar la opción seleccionada
		if(receivedChar != 0){
			switch(receivedChar){
				case '1':
				// Código para leer el valor del potenciómetro y mostrarlo en UART
				break;
				case '2':
				// Código para enviar un caracter ASCII
				break;
			}
			menuActivo = 0; // Volver al menú principal
			receivedChar = 0; // Reiniciar la variable
		}
	}
}

void iniciarUART9600(void)
{
	// Configuración de pines RX y TX como entrada y salida, respectivamente
	DDRD &= ~(1<<DDD0);
	DDRD |= (1<<DDD1);

	// Habilitar interrupción de recepción y habilitar RX y TX
	UCSR0B |= (1<<RXCIE0) | (1<<RXEN0) | (1<<TXEN0);

	// Configuración asincrónica, sin paridad, 1 bit de stop, 8 bits de datos
	UCSR0C |= (1<<UCSZ01) | (1<<UCSZ00);

	// Configuración de velocidad a 9600
	UBRR0 = 103;
}

void iniciarADC(){
	ADMUX = 6;  // ADC6 como entrada
	ADMUX |= (1<<REFS0);  // Referencia AVCC = 5V
	ADMUX &= ~(1<<REFS1); // Justificación a la izquierda
	ADMUX |= (1<<ADLAR);
	ADCSRA = 0;
	ADCSRA |= (1<<ADIE);  // Habilitar interrupción de ADC
	ADCSRA |= (1<<ADPS2) | (1<<ADPS1) | (1<<ADPS0);  // Habilitar prescaler de 16M/128 frecuencia = 125Khz
	ADCSRA |= (1<<ADEN);   // Habilitar el ADC
}

ISR(ADC_vect)
{
	datoADC = ADCH;   // Leer el dato del ADC
	ADCSRA |= (1<<ADIF); // Borrar la bandera de interrupción
}

// Función para escribir un caracter en UART
void escribirUART(char Caracter)
{
	while(!(UCSR0A & (1<<UDRE0)));  // Esperar hasta que la bandera esté en 1
	UDR0 = Caracter;
}

// Función para escribir una cadena de caracteres en UART
void escribirTextoUART(const char *Texto){
	uint8_t i = 0;
	while(Texto[i] != '\0'){
		while(!(UCSR0A & (1<<UDRE0)));
		UDR0 = Texto[i];
		i++;
	}
}

ISR(USART_RX_vect)
{
	receivedChar = UDR0; // Almacenar el carácter recibido

	if (activa2 == 1){    // Se eligió enviar un carácter
		// Dividir el carácter recibido en dos partes
		uint8_t lower_bits = receivedChar & 0b00111111; // Los 6 bits menos significativos
		uint8_t upper_bits = (receivedChar >> 6) & 0b11; // Los 2 bits más significativos

		// Mostrar los 6 bits menos significativos en PORTB
		PORTB = lower_bits;

		// Mostrar los 2 bits más significativos en los pines PD6 y PD7 de PORTD
		PORTD = (PORTD & ~0b11000000) | (upper_bits << 6);

		activa2 = 0;   // Salir de este if
		activa = 0;  // Entrar al menú principal
	}

	while(!(UCSR0A & (1<<UDRE0)));    // Mientras haya caracteres
	UDR0 = receivedChar; // Enviar el carácter recibido por UART
}
