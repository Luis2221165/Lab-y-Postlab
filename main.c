//***************************************************************************
//Universidad del valle de Guatemala
//IE2023: Programación de Microcontroladores
//Autor: Luis Angel Ramirez Orózco
//Proyecto: PreLab
//Hardware: ATMEGA328P
//Creado: 05/04/2024
//***************************************************************************
//***************************************************************************
//***************************************************************************

#define F_CPU 20000000UL
#include <avr/io.h>
#include <util/delay.h>

#define BOTON_INCREMENTO_PIN 0 // D8
#define BOTON_DECREMENTO_PIN 1 // D9

// Definición de los patrones de segmentos para los dígitos hexadecimales
const uint8_t display_data[16] = {
	0x3F, // 0
	0x06, // 1
	0x5B, // 2
	0x4F, // 3
	0x66, // 4
	0x6D, // 5
	0x7D, // 6
	0x07, // 7
	0x7F, // 8
	0x6F, // 9
	0x77, // A
	0x7C, // B
	0x39, // C
	0x5E, // D
	0x79, // E
	0x71  // F
};

int main(void) {
	DDRD |= 0xFE; // D1-D7 como salidas
	DDRA |= 0x0F; // A0-A3 como salidas

	// Configurar USART para comunicación serial
	UBRR0H = (unsigned char)(103 >> 8); // Configurar baud rate a 9600bps
	UBRR0L = (unsigned char)103;
	UCSR0B = (1 << RXEN0) | (1 << TXEN0); // Habilitar transmisión y recepción
	UCSR0C = (1 << UCSZ01) | (1 << UCSZ00); // Configurar frame de datos: 8 bits de datos, 1 bit de stop, sin paridad

	// Definir el rango de valores del potenciómetro
	const uint16_t POT_MIN = 0;
	const uint16_t POT_MAX = 1023;
	const uint8_t HEX_MAX = 15;

	uint8_t contador = 0;
	uint8_t estado_anterior_incremento = 1;
	uint8_t estado_anterior_decremento = 1;

	while (1) {
		uint8_t boton_incremento = !(PINC & (1 << BOTON_INCREMENTO_PIN));
		uint8_t boton_decremento = !(PINC & (1 << BOTON_DECREMENTO_PIN));

		_delay_ms(20);

		uint8_t boton_incremento_antirrebote = !(PINC & (1 << BOTON_INCREMENTO_PIN));
		uint8_t boton_decremento_antirrebote = !(PINC & (1 << BOTON_DECREMENTO_PIN));

		if (boton_incremento_antirrebote && !estado_anterior_incremento) {
			contador++;
		}

		if (boton_decremento_antirrebote && !estado_anterior_decremento) {
			contador--;
		}

		estado_anterior_incremento = boton_incremento_antirrebote;
		estado_anterior_decremento = boton_decremento_antirrebote;

		while (!(UCSR0A & (1 << UDRE0))); // Esperar a que el buffer de transmisión esté vacío
		UDR0 = contador;

		// Asegurar que el contador esté en el rango de 0 a 15 (hexadecimal)
		if (contador > HEX_MAX) {
			contador = HEX_MAX;
			} else if (contador < 0) {
			contador = 0;
		}

		// Leer el valor del potenciómetro en A5
		uint16_t pot_value = analogRead(A5);
		
		// Convertir el valor del potenciómetro al rango de 0 a 15
		uint8_t display_value = map(pot_value, POT_MIN, POT_MAX, 0, HEX_MAX);

		// Mostrar el valor en los displays
		PORTA |= (1 << 0); // Activar el primer transistor para los displays
		PORTD = display_data[contador]; // Mostrar el valor del contador en el primer display
		_delay_ms(5); // Breve retardo para visualización
		PORTA &= ~(1 << 0); // Desactivar el primer transistor para los displays

		PORTA |= (1 << 1); // Activar el segundo transistor para los displays
		PORTD = display_data[display_value]; // Mostrar el valor del potenciómetro en el segundo display
		_delay_ms(5); // Breve retardo para visualización
		PORTA &= ~(1 << 1); // Desactivar el segundo transistor para los displays
		
		// Encender el LED en A3 si el contador es menor que el valor del display
		if (contador < display_value) {
			PORTA |= (1 << 3);
			} else {
			PORTA &= ~(1 << 3);
		}
	}

	return 0;
}
