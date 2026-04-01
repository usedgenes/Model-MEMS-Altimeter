#include "Bluetooth.h"
#include "Altimeter.h"

#define SPI1_SCK 32
#define SPI1_MISO 35
#define SPI1_MOSI 33
#define SPI1_CS 12

SPIClass* vspi = NULL;

Bluetooth bluetooth;
Altimeter altimeter;

unsigned long currentTime = 0;
unsigned long previousTime = 0;

unsigned long lastDataLog = 0;

float currentAltitude = 0;
float currentTemperature = 0;
float currentPressure = 0;


bool sendBluetoothData = false;
bool bluetoothConnected = false;
bool sendBluetoothAltimeter = false;

void setup() {
  Serial.begin(115200);
  bluetooth.Init(&altimeter, &bluetoothConnected, &sendBluetoothAltimeter);
  while (!bluetoothConnected) {
    delay(1000);
  }
  vspi = new SPIClass(VSPI);
  vspi->begin(SPI1_SCK, SPI1_MISO, SPI1_MOSI, SPI1_CS);

  if (!altimeter.Init(vspi, SPI1_CS)) {
    bluetooth.writeUtilitiesNotifications("Altimeter Initialization Error");
    Serial.println("BMP390 Initialization Error");
    while (1) {}
  }

  bluetooth.writeUtilitiesEvents("Started");
  Serial.println("Started");
}

void loop() {
  currentAltitude = altimeter.getAltitude();
  altimeter.getTempAndPressure(currentTemperature, currentPressure);
  logData(1000);
}

void logData(int dataLoggingFrequencyInMilliseconds) {
  if (millis() - lastDataLog >= dataLoggingFrequencyInMilliseconds) {
    lastDataLog = millis();
    if (sendBluetoothAltimeter) {
      Serial.println("Sending Bluetooth Altimeter");
      bluetooth.writeAltimeter("90" + String(currentAltitude));
      bluetooth.writeAltimeter("91" + String(currentTemperature));
      bluetooth.writeAltimeter("92" + String(currentPressure));
    }
    Serial.println("Altitude: " + String(currentAltitude) + "\tTemperature: " + String(currentTemperature) + "\tPressure: " + String(currentPressure));

  }
}