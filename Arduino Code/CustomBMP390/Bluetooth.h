
#ifndef BLUETOOTH_H_
#define BLUETOOTH_H_

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include "Altimeter.h"

class Bluetooth {
#define DEVICE_NAME "BMP390"
#define SERVICE_UUID "9a8ca9ef-e43f-4157-9fee-c37a3d7dc12d"
#define BMP390_UUID "94cbc7dc-ff62-4958-9665-0ed477877581"
#define UTILITIES_UUID "fb02a2fa-2a86-4e95-8110-9ded202af76b"
private:
  BLECharacteristic *pBMP390;
  BLECharacteristic *pUtilities;

  Altimeter *altimeter;

  bool *bluetoothConnected;
  bool *sendBluetoothAltimeter;

public:
  void Init(Altimeter *_altimeter, bool *_bluetoothConnected, bool *_sendBluetoothAltimeter);
  void writeAltimeter(String message);
  void writeUtilitiesNotifications(String message);
  void writeUtilitiesEvents(String message);
  void writeUtilities(String message);
};


class MyServerCallbacks : public BLEServerCallbacks {
private:
  bool *bluetoothConnected;
  void (*resetFunc)(void) = 0;
public:
  MyServerCallbacks(bool *_bluetoothConnected) {
    bluetoothConnected = _bluetoothConnected;
  }
  void onConnect(BLEServer *pServer) {
    Serial.println("Connected");
    *bluetoothConnected = true;
  };
  void onDisconnect(BLEServer *pServer) {
    Serial.println("Disconnected");
    *bluetoothConnected = false;
    resetFunc();
  };
};

class UtilitiesCallbacks : public BLECharacteristicCallbacks {
private:
  bool *sendLoopTime;
  bool *sendBluetoothAltimeter;

public:
  void (*resetFunc)(void) = 0;
  UtilitiesCallbacks(bool *_sendBluetoothAltimeter) {
    sendBluetoothAltimeter = _sendBluetoothAltimeter;
  };
  void onWrite(BLECharacteristic *pCharacteristic) {
    String value = pCharacteristic->getValue();
    if (value == "Reset") {
      resetFunc();
    } else if (value == "BMP390 Get") {
      *sendBluetoothAltimeter = true;
    } else if (value == "BMP390 Stop") {
      *sendBluetoothAltimeter = false;
    }
  };
};

class BMP390Callbacks : public BLECharacteristicCallbacks {
private:
  Altimeter *altimeter;
public:
  BMP390Callbacks(Altimeter *_altimeter) {
    altimeter = _altimeter;
  };
  void onWrite(BLECharacteristic *pCharacteristic) {
    String value = pCharacteristic->getValue();
    if (value == "Tare") {
      altimeter->tare();
    }
  };;
};
#endif
