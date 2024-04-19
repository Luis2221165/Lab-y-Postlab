#ifndef PWM0_H_   // Directiva del preprocesador: comprueba si PWM0_H_ no está definido
#define PWM0_H_   // Si no está definido, define PWM0_H_

#include <avr/io.h>   // Incluye el archivo de encabezado de AVR para acceder a las definiciones de registros de E/S

#define NO_INVERTING    1   // Definición de una constante NO_INVERTING con el valor 1
#define INVERTING       0   // Definición de una constante INVERTING con el valor 0

#define POTENTIOMETER_1_PIN  0   // Definición del pin del primer potenciómetro (A0)
#define POTENTIOMETER_2_PIN  1   // Definición del pin del segundo potenciómetro (A1)
#define LED_PIN              10  // Definición del pin del LED (D10)

void PWM0_init(void);       // Prototipo de la función PWM0_init, que inicializa el módulo PWM0
void PWM0_dca(uint8_t dc, uint8_t modo);  // Prototipo de la función PWM0_dca, que configura el ciclo de trabajo del PWM0 para el canal A
void PWM0_dcb(uint8_t dc, uint8_t modo);  // Prototipo de la función PWM0_dcb, que configura el ciclo de trabajo del PWM0 para el canal B

#endif /* PWM0_H_ */   // Fin de la directiva del preprocesador, indica el final de la definición de PWM0_H_
