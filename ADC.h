#ifndef ADC_H_   // Directiva del preprocesador: comprueba si ADC_H_ no está definido
#define ADC_H_   // Si no está definido, define ADC_H_

#include <avr/io.h>   // Incluye el archivo de encabezado de AVR para acceder a las definiciones de registros de E/S

void ADC_init(void);       // Prototipo de la función ADC_init, que inicializa el módulo ADC
uint16_t ADC_read(uint8_t canal);   // Prototipo de la función ADC_read, que lee el valor analógico del canal especificado

#endif /* ADC_H_ */   // Fin de la directiva del preprocesador, indica el final de la definición de ADC_H_
