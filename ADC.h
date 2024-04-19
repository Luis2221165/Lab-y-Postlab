#ifndef ADC_H_   // Directiva del preprocesador: comprueba si ADC_H_ no est� definido
#define ADC_H_   // Si no est� definido, define ADC_H_

#include <avr/io.h>   // Incluye el archivo de encabezado de AVR para acceder a las definiciones de registros de E/S

void ADC_init(void);       // Prototipo de la funci�n ADC_init, que inicializa el m�dulo ADC
uint16_t ADC_read(uint8_t canal);   // Prototipo de la funci�n ADC_read, que lee el valor anal�gico del canal especificado

#endif /* ADC_H_ */   // Fin de la directiva del preprocesador, indica el final de la definici�n de ADC_H_
