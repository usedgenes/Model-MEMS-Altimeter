#ifndef ALTIMETER_H_
#define ALTIMETER_H_

#include <Adafruit_Sensor.h>
#include "Adafruit_BMP3XX.h"

class Altimeter {

#define SEALEVELPRESSURE_HPA (1013.25)

private:
  Adafruit_BMP3XX bmp;
  float previousAltitude;
  float alpha;
  int BMP_CS;
  float taredAltitude;
public:
  bool Init(SPIClass * vspi, int _BMP_CS);
  void getTempAndPressure(float& temperature, float& pressure);
  float getAltitude();
  void tare();
};

#endif
