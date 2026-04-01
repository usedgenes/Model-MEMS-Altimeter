
#ifndef BLUETOOTH_H_
#define BLUETOOTH_H_

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include "Altimeter.h"

class Bluetooth {
#define DEVICE_NAME "HX711"
#define SERVICE_UUID "9a8ca9ef-e43f-4157-9fee-c37a3d7dc12d"
#define HX711_UUID "c91b34b8-90f3-4fee-89f7-58c108ab198f"
#define UTILITIES_UUID "fb02a2fa-2a86-4e95-8110-9ded202af76b"
private:
  BLECharacteristic *pHX711;
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
  void (*resetFunc)(void) = 0;
  bool *bluetoothConnected;
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
    } else if (value == "HX711 Get") {
      *sendBluetoothAltimeter = true;
    } else if (value == "HX711 Stop") {
      *sendBluetoothAltimeter = false;
    }
  };
};

class HX711Callbacks : public BLECharacteristicCallbacks {
private:
  Altimeter *altimeter;
public:
  HX711Callbacks(Altimeter *_altimeter) {
    altimeter = _altimeter;
  };
  void onWrite(BLECharacteristic *pCharacteristic){
    String value = pCharacteristic->getValue();
    if (value == "Tare") {
      altimeter->tareAltimeter();
    }
  };
};
#endif
