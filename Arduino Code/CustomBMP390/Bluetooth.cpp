
#include "Bluetooth.h"

void Bluetooth::Init(Altimeter *_altimeter, bool *_bluetoothConnected, bool *_sendBluetoothAltimeter) {
  altimeter = _altimeter;
  bluetoothConnected = _bluetoothConnected;
  sendBluetoothAltimeter = _sendBluetoothAltimeter;

  String devName = DEVICE_NAME;

  BLEDevice::init(devName.c_str());
  BLEServer* pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks(bluetoothConnected));
  BLEService* pService = pServer->createService(SERVICE_UUID);

  pBMP390 = pService->createCharacteristic(BMP390_UUID, BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY | BLECharacteristic::PROPERTY_WRITE);
  pBMP390->setCallbacks(new BMP390Callbacks(altimeter));

  pUtilities = pService->createCharacteristic(UTILITIES_UUID, BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY | BLECharacteristic::PROPERTY_WRITE);
  pUtilities->setCallbacks(new UtilitiesCallbacks(sendBluetoothAltimeter));

  pService->start();

  BLEAdvertising* pAdvertising = pServer->getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);

  pAdvertising->start();
}

void Bluetooth::writeUtilitiesNotifications(String message) {
  pUtilities->setValue("1" + message);
  pUtilities->notify();
}

void Bluetooth::writeUtilitiesEvents(String message) {
  pUtilities->setValue("2" + message);
  pUtilities->notify();
}

void Bluetooth::writeUtilities(String message) {
  pUtilities->setValue(message);
  pUtilities->notify();
}

void Bluetooth::writeAltimeter(String message) {
  pBMP390->setValue(message);
  pBMP390->notify();
}

