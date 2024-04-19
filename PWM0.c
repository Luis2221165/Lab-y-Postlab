#include "PWM0.h"

void PWM0_init(void)
{
	// Configuración del modo Fast PWM para el Timer 0
	TCCR0A |= (1<<WGM01) | (1<<WGM00);    // Configura los bits WGM01 y WGM00 para seleccionar el modo Fast PWM
	TCCR0B &= ~(1<<WGM02);                // Borra el bit WGM02 para seleccionar el modo Fast PWM
	
	// Desactiva cualquier configuración previa del prescalador para el Timer 0
	TCCR0B &= ~(1 << CS02) & ~(1 << CS01) & ~(1 << CS00); // Borra los bits CS02, CS01 y CS00
	
	// Configura el prescalador en 1024 para el Timer 0
	TCCR0B |= (1 << CS02) | (1 << CS00); // Configura los bits CS02 y CS00 para establecer el prescalador en 1024
}

void PWM0_dca(uint8_t dc, uint8_t modo)
{
	// Configuración del pin OC0A (D6) como salida
	DDRD |= (1 << DDD6);

	if(modo == INVERTING)
	{
		TCCR0A |= (1<<COM0A1);   // Configura el bit COM0A1 para habilitar la salida no inversora en el pin OC0A
		TCCR0A &= ~(1<<COM0A0);  // Borra el bit COM0A0 para habilitar la salida no inversora en el pin OC0A
	}
	else
	{
		TCCR0A |= (1<<COM0A1);   // Configura el bit COM0A1 para habilitar la salida no inversora en el pin OC0A
		TCCR0A |= (1<<COM0A0);   // Configura el bit COM0A0 para habilitar la salida inversora en el pin OC0A
	}

	OCR0A = (dc * 255) / 100;   // Establece el ciclo de trabajo en el valor proporcionado (en porcentaje)
}

void PWM0_dcb(uint8_t dc, uint8_t modo)
{
	// Configuración del pin OC0B (D5) como salida
	DDRD |= (1 << DDD5);

	if(modo == INVERTING)
	{
		TCCR0A |= (1<<COM0B1);   // Configura el bit COM0B1 para habilitar la salida no inversora en el pin OC0B
		TCCR0A &= ~(1<<COM0B0);  // Borra el bit COM0B0 para habilitar la salida no inversora en el pin OC0B
	}
	else
	{
		TCCR0A |= (1<<COM0B1);   // Configura el bit COM0B1 para habilitar la salida no inversora en el pin OC0B
		TCCR0A |= (1<<COM0B0);   // Configura el bit COM0B0 para habilitar la salida inversora en el pin OC0B
	}

	OCR0B = (dc * 255) / 100;   // Establece el ciclo de trabajo en el valor proporcionado (en porcentaje)
}
