#include "Altimeter.h"

bool Altimeter::Init() {
  unsigned int startTime = millis();
  altimeter.begin(DOUT_PIN, SCK_PIN);
  altimeter.set_scale(CALIBRATION_FACTOR);
  while (millis() - startTime < 15000) {
    float units = altimeter.get_units(10);
    long raw = altimeter.read_average(10);
  }
  altimeter.tare();
  return true;
}

void Altimeter::tareAltimeter(){
  altimeter.tare();
}

float Altimeter::getAltitude() {
  if (altimeter.is_ready()) {
    float rawWeight = altimeter.get_units(5);  // Get 1 fresh reading

    // The EMA Formula
    filteredWeight = (alpha * rawWeight) + ((1.0 - alpha) * filteredWeight);

    // Now use filteredWeight in your altitude calculation
    float currentP = 101325.0 + (4.63 * filteredWeight);
    float altitude = 44330.0 * (1.0 - pow((currentP / 101325.0), 0.1903));

    return altitude;
  } else {
    return -1;
  }
}



