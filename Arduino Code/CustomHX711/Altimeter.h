#ifndef ALTIMETER_H_
#define ALTIMETER_H_

#include "HX711.h"

class Altimeter {

#define CALIBRATION_FACTOR  -250

const int DOUT_PIN = 21;
const int SCK_PIN = 22;
 
private:
  HX711 altimeter;
  float filteredWeight = 0;
  float alpha = 0.3; // Tuning factor (0.0 to 1.0)
public:
  bool Init();
  void tareAltimeter();
  float getAltitude();
};

#endif
