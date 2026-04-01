#include "Altimeter.h"

bool Altimeter::Init(SPIClass * vspi, int _BMP_CS) {
  BMP_CS = _BMP_CS;
  
  if (!bmp.begin_SPI(BMP_CS, vspi)) {  // software SPI mode
    return false;
  }
  bmp.setTemperatureOversampling(BMP3_OVERSAMPLING_8X);
  bmp.setPressureOversampling(BMP3_OVERSAMPLING_4X);
  bmp.setIIRFilterCoeff(BMP3_IIR_FILTER_COEFF_3);
  bmp.setOutputDataRate(BMP3_ODR_50_HZ);
  //first reading is usually garbage
  for (int i = 0; i < 5; i++) {
    bmp.performReading();
    delay(10);
    // Serial.println("BMP Initial Readings: " + String(bmp.readAltitude(SEALEVELPRESSURE_HPA)));
  }
  bmp.performReading();
  taredAltitude = bmp.readAltitude(SEALEVELPRESSURE_HPA);
  return true;
}

void Altimeter::getTempAndPressure(float& temperature, float& pressure) {
  while (!bmp.performReading()) {}
  temperature = bmp.temperature;
  pressure = bmp.pressure;
  digitalWrite(BMP_CS, HIGH);
}

void Altimeter::tare() {
  taredAltitude = bmp.readAltitude(SEALEVELPRESSURE_HPA);
}

float Altimeter::getAltitude() {
  bmp.performReading();
  while (isnan(bmp.readAltitude(SEALEVELPRESSURE_HPA))) {
    bmp.performReading();
  }
  return bmp.readAltitude(SEALEVELPRESSURE_HPA) - taredAltitude;
}
