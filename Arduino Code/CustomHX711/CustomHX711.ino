#include "Bluetooth.h"
#include "Altimeter.h"

Bluetooth bluetooth;
Altimeter altimeter;

unsigned long currentTime = 0;
unsigned long previousTime = 0;
unsigned long loopTime = 0;

unsigned long lastDataLog = 0;

float currentAltitude = 0;

bool sendBluetoothData = false;
bool bluetoothConnected = false;
bool sendBluetoothAltimeter = false;

void setup() {
  Serial.begin(115200);
  bluetooth.Init(&altimeter, &bluetoothConnected, &sendBluetoothAltimeter);
  while (!bluetoothConnected) {
    delay(1000);
  }

  if (!altimeter.Init()) {
    bluetooth.writeUtilitiesNotifications("Altimeter Initialization Error");
    Serial.println("HX711 Initialization Error");
  }

  bluetooth.writeUtilitiesEvents("HX 711 Started");
  Serial.println("HX711 Started");
}

void loop() {
  logData(1000);
}

void logData(int dataLoggingFrequencyInMilliseconds) {
  if (millis() - lastDataLog >= dataLoggingFrequencyInMilliseconds) {
    lastDataLog = millis();
    currentAltitude = altimeter.getAltitude();
    if (sendBluetoothAltimeter) {
      Serial.println("Sending Bluetooth Altimeter");
      bluetooth.writeAltimeter("90" + String(currentAltitude));
    }
    Serial.println("Altitude: " + String(currentAltitude));
  }
}