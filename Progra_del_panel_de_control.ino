const int analogInPin1 = A0;  // Pin analógico al que está conectado el potenciómetro
int sensorValue1 = 0;          // Valor leído del potenciómetro
int outputValue1 = 0;          // Valor de salida mapeado

const int analogInPin2 = A1;  // Pin analógico al que está conectado el potenciómetro
int sensorValue2 = 0;          // Valor leído del potenciómetro
int outputValue2 = 0;          // Valor de salida mapeado

const int analogInPin3 = A2;  // Pin analógico al que está conectado el potenciómetro
int sensorValue3 = 0;          // Valor leído del potenciómetro
int outputValue3 = 0;          // Valor de salida mapeado

const int analogInPin4 = A3;  // Pin analógico al que está conectado el potenciómetro
int sensorValue4 = 0;          // Valor leído del potenciómetro
int outputValue4 = 0;          // Valor de salida mapeado

void setup() {
  // Inicializar la comunicación serial a 9600 bps:
  Serial.begin(9600);
}

void loop() {
  // Leer el valor analógico:
  sensorValue1 = analogRead(analogInPin1);
  // Mapearlo al rango de la salida analógica:
  outputValue1 = 100+map(sensorValue1, 0, 1023, 0, 255);

  // Leer el valor analógico:
  sensorValue2 = analogRead(analogInPin2);
  // Mapearlo al rango de la salida analógica:
  outputValue2 = 100+map(sensorValue2, 0, 1023, 0, 255);

  // Leer el valor analógico:
  sensorValue3 = analogRead(analogInPin3);
  // Mapearlo al rango de la salida analógica:
  outputValue3 = 100+map(sensorValue3, 0, 1023, 0, 255);

  // Leer el valor analógico:
  sensorValue4 = analogRead(analogInPin4);
  // Mapearlo al rango de la salida analógica:
 outputValue4 = 100+map(sensorValue4, 0, 1023, 0, 255);

  // Imprimir los resultados en el Monitor Serie:
  Serial.print(outputValue1);
  Serial.print(",");
  Serial.print(outputValue2);
  Serial.print(",");
  Serial.print(outputValue3);
  Serial.print(",");
  Serial.println(outputValue4);

  // Esperar 250 milisegundos antes del próximo ciclo para que el conversor analógico-digital
  // se estabilice después de la última lectura:
  delay(250);
}
