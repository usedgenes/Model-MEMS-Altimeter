//To add new device:
//create new device cbcharacteristic variable
//update the three peripheral functions in extension BTDevice: CBPeripheralDelegate
//create a function in BTDevice
import Foundation
import CoreBluetooth

protocol BTDeviceDelegate: AnyObject {
    func deviceConnected(_ device: BTDevice)
    func deviceReady(_ device: BTDevice, supportsBMP390: Bool, supportsHX711: Bool)
    func deviceSerialChanged(_ device: BTDevice, value: String)
    func deviceDisconnected(_ device: BTDevice)
    
}

class BTDevice: NSObject {
    private let peripheral: CBPeripheral
    private let manager: CBCentralManager
    
    private var bmp390Char: CBCharacteristic?
    private var hx711Char: CBCharacteristic?
    
    private var utilitiesChar: CBCharacteristic?
    
    var bmp390: BMP390?
    var hx711: HX711?
    
    weak var delegate: BTDeviceDelegate?
    
    private var supportsBMP390: Bool = false
    private var supportsHX711: Bool = false
    
    var identifier: UUID { peripheral.identifier }
    
    var utilitiesString: String {
        get {
            return "-1"
        }
        set {
            if let char = utilitiesChar {
                peripheral.writeValue(Data(newValue.utf8), for: char, type: .withResponse)
            }
        }
    }
    
    var bmp390String: String {
        get {
            return "-1"
        }
        set {
            if let char = bmp390Char {
                peripheral.writeValue(Data(newValue.utf8), for: char, type: .withResponse)
            }
        }
    }
    
    var hx711String: String {
        get {
            return "-1"
        }
        set {
            if let char = hx711Char {
                peripheral.writeValue(Data(newValue.utf8), for: char, type: .withResponse)
            }
        }
    }
    
    var name: String {
        return peripheral.name ?? "Unknown device"
    }
    var detail: String {
        return peripheral.identifier.description
    }
    private(set) var serial: String?
    
    init(peripheral: CBPeripheral, manager: CBCentralManager) {
        self.peripheral = peripheral
        self.manager = manager
        super.init()
        self.peripheral.delegate = self
    }
    
    func connect() {
        manager.connect(peripheral, options: nil)
    }
    
    func disconnect() {
        manager.cancelPeripheralConnection(peripheral)
    }
    
    func intToChar(number: Int) -> [Character] {
        return Array(String(number))
    }
}

extension BTDevice {
    // these are called from BTManager, do not call directly
    
    func connectedCallback() {
        peripheral.discoverServices([BTUUIDs.esp32Service])
        delegate?.deviceConnected(self)
    }
    
    func disconnectedCallback() {
        delegate?.deviceDisconnected(self)
    }
    
    func errorCallback(error: Error?) {
        print("Device: error \(String(describing: error))")
    }
}


extension BTDevice: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Device: discovered services")
        peripheral.services?.forEach {
            print("  \($0)")
            if $0.uuid == BTUUIDs.esp32Service {
                peripheral.discoverCharacteristics([BTUUIDs.esp32Service, BTUUIDs.bmp390UUID, BTUUIDs.utilitiesUUID, BTUUIDs.hx711UUID], for: $0)
            } else {
                peripheral.discoverCharacteristics(nil, for: $0)
            }
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // Reset capabilities for this discovery cycle.
        supportsBMP390 = false
        supportsHX711 = false
        
        service.characteristics?.forEach {
            if $0.uuid == BTUUIDs.bmp390UUID {
                self.bmp390Char = $0
                supportsBMP390 = true
                peripheral.readValue(for: $0)
                peripheral.setNotifyValue(true, for: $0)
            } else if $0.uuid == BTUUIDs.utilitiesUUID {
                self.utilitiesChar = $0
                peripheral.readValue(for: $0)
                peripheral.setNotifyValue(true, for: $0)
            } else if $0.uuid == BTUUIDs.hx711UUID {
                self.hx711Char = $0
                supportsHX711 = true
                peripheral.readValue(for: $0)
                peripheral.setNotifyValue(true, for: $0)
            }
        }
        delegate?.deviceReady(self, supportsBMP390: supportsBMP390, supportsHX711: supportsHX711)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == bmp390Char?.uuid, let b = characteristic.value {
            var value = String(decoding: b, as: UTF8.self)
            if(value != "") {
                if(value[...value.startIndex] == "9") {
                    value.remove(at: value.startIndex)
                    if(value[...value.startIndex] == "0") {
                        value.remove(at: value.startIndex)
                        bmp390!.addAltitude(altitude: Float(value)!)
                        return;
                    }
//                    if(value[...value.startIndex] == "1") {
//                        value.remove(at: value.startIndex)
//                        bmp390!.addTemperature(temperature: Float(value)!)
//                        return;
//                    }
//                    if(value[...value.startIndex] == "2") {
//                        value.remove(at: value.startIndex)
//                        bmp390!.addPressure(pressure: Float(value)!)
//                        return;
//                    }
                }
            }
        }
        
        else if characteristic.uuid == utilitiesChar?.uuid, let b = characteristic.value {
            var value = String(decoding: b, as: UTF8.self)
            if(value != "") {
                if(value[...value.startIndex] == "2") {
                    value.remove(at: value.startIndex)
                    if(value[...value.startIndex] == "1") {
                        hx711?.calibrationDone()

                    }
                }
            }
        }
        
        if characteristic.uuid == hx711Char?.uuid, let b = characteristic.value {
            var value = String(decoding: b, as: UTF8.self)
            if(value != "") {
                if(value[...value.startIndex] == "9") {
                    value.remove(at: value.startIndex)
                    if(value[...value.startIndex] == "0") {
                        value.remove(at: value.startIndex)
                        hx711!.addAltitude(altitude: Float(value)!)
                        return;
                    }
                }
            }
        }
    }
}


