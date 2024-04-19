#include "ADC.h"

void ADC_init(void)
{
	ADMUX |= (1<<REFS0);    // Seleccionar el voltaje de referencia
	ADMUX &= ~(1<<REFS1);
	ADMUX &= ~(1<<ADLAR);   // Ajustar el resultado

	ADCSRA |= (1<<ADPS0);   // Divisor = 128  16000/128 = 125 KHz
	ADCSRA |= (1<<ADPS1);
	ADCSRA |= (1<<ADPS2);
	ADCSRA |= (1<<ADEN);    // Encendemos en ADC
}

uint16_t ADC_read(uint8_t canal)
{
	canal &= 0b00001111;                // Limitar la entrada a 5
	ADMUX = (ADMUX & 0xF0) | canal;     // Limpiar los últimos 4 bits de ADMUX, OR con ch
	ADCSRA |= (1<<ADSC);                // Inicia la conversión
	while(ADCSRA & (1<<ADSC));          // Hasta que se complete la conversión
	return ADC;                         // Devuelve el valor del ADC
}

