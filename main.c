//***************************************************************************
//Universidad del valle de Guatemala
//IE2023: Programación de Microcontroladores
//Autor: Luis Angel Ramirez Orózco
//Proyecto: PreLab5
//Hardware: ATMEGA328P
//Creado: 25/01/2024
//***************************************************************************
//***************************************************************************
//***************************************************************************

#include <avr/io.h>
#include "PWM0/PWM0.h"  // Incluye el archivo de encabezado para la configuración y funciones de PWM
#include "ADC/ADC.h"    // Incluye el archivo de encabezado para la configuración y funciones de ADC

int main(void)
{
    DDRD |= (1 << DDD6); // Configura el pin D6 (OC0A) como salida para el PWM
    DDRB |= (1 << DDB2); // Configura el pin D10 (PB2) como salida para el LED
    
    PWM0_init();   // Inicializa el módulo PWM
    ADC_init();    // Inicializa el módulo ADC

    PWM0_dcb(10, INVERTING);  // Configura el ciclo de trabajo del PWM al 10% y la salida en modo inversor
    
    while (1)
    {
        float adc = ADC_read(0);    // Lee el valor del canal 0 (A0) del ADC
        adc = (adc * 100) / 1023;   // Convierte el valor del ADC a un porcentaje (0-100)
        PWM0_dca((uint8_t)adc, NO_INVERTING);  // Configura el ciclo de trabajo del PWM con el porcentaje leído del ADC y la salida en modo no inversor
        
        // Enciende el LED (D10) si el valor del ADC es mayor a un cierto umbral
        if (adc > 50) {
            PORTB |= (1 << PORTB2); // Enciende el LED conectado al pin D10
        } else {
            PORTB &= ~(1 << PORTB2); // Apaga el LED conectado al pin D10
        }
    }
}
