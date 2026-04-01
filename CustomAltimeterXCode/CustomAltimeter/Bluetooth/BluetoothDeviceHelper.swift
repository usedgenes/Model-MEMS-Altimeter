//
//  BluetoothDeviceHelper.swift
//  ESP 32 Interface
//
//  Created by Eugene on 7/26/24.
//

import Foundation
import UserNotifications

class BluetoothDeviceHelper: ObservableObject {
    @Published var refreshBluetooth: Bool = false

    // One cached BTDevice per physical peripheral (keyed by peripheral UUID).
    @Published private(set) var connectedDevices: [UUID: BTDevice] = [:]

    // Exactly one active sensor model per sensor type.
    @Published private(set) var bmp390: BMP390?
    @Published private(set) var hx711: HX711?

    @Published private(set) var bmp390DeviceId: UUID?
    @Published private(set) var hx711DeviceId: UUID?

    @Published private(set) var connectedDeviceNames: [UUID: String] = [:]

    @Published private(set) var statusText: String = "Not connected"

    enum SensorType {
        case bmp390
        case hx711
    }

    func refresh() {
        refreshBluetooth.toggle()
    }

    var isConnected: Bool {
        !connectedDevices.isEmpty
    }

    private func updateStatusText() {
        let hasBmp = bmp390 != nil
        let hasHx = hx711 != nil
        switch (hasBmp, hasHx) {
        case (false, false):
            statusText = "Not connected"
        case (false, true):
            statusText = "HX711 connected"
        case (true, false):
            statusText = "BMP390 connected"
        default:
            statusText = "BMP390 + HX711 connected"
        }
    }

    func disconnectAll() {
        for (_, device) in connectedDevices {
            device.disconnect()
        }
        connectedDevices.removeAll()
        bmp390 = nil
        hx711 = nil
        bmp390DeviceId = nil
        hx711DeviceId = nil
        connectedDeviceNames.removeAll()
        statusText = "Not connected"
    }

    // User assigns a peripheral as BMP390 and/or HX711. No "modes": we just attach the
    // corresponding models and let notifications fill in data when present.
    func connect(device: BTDevice, as sensorType: SensorType) {
        let id = device.identifier

        let alreadyKnown = connectedDevices[id] != nil
        connectedDevices[id] = device
        connectedDeviceNames[id] = device.name

        device.delegate = self

        switch sensorType {
        case .bmp390:
            // Detach BMP390 from any previously assigned device.
            if let prevId = bmp390DeviceId, prevId != id, let prevDevice = connectedDevices[prevId] {
                prevDevice.bmp390 = nil
                // If that device is not used by HX711, drop it entirely.
                if hx711DeviceId != prevId {
                    prevDevice.disconnect()
                    connectedDevices.removeValue(forKey: prevId)
                    connectedDeviceNames.removeValue(forKey: prevId)
                }
            }

            if bmp390 == nil { bmp390 = BMP390() }
            bmp390DeviceId = id
            device.bmp390 = bmp390

        case .hx711:
            // Detach HX711 from any previously assigned device.
            if let prevId = hx711DeviceId, prevId != id, let prevDevice = connectedDevices[prevId] {
                prevDevice.hx711 = nil
                // If that device is not used by BMP390, drop it entirely.
                if bmp390DeviceId != prevId {
                    prevDevice.disconnect()
                    connectedDevices.removeValue(forKey: prevId)
                    connectedDeviceNames.removeValue(forKey: prevId)
                }
            }

            if hx711 == nil { hx711 = HX711() }
            hx711DeviceId = id
            device.hx711 = hx711
        }

        // Only trigger an actual BLE connect the first time we see this peripheral.
        if !alreadyKnown {
            device.connect()
        }

        updateStatusText()
    }

    func disconnectDevice(id: UUID) {
        connectedDevices[id]?.disconnect()
        connectedDevices.removeValue(forKey: id)
        connectedDeviceNames.removeValue(forKey: id)

        if bmp390DeviceId == id {
            bmp390DeviceId = nil
            bmp390 = nil
        }
        if hx711DeviceId == id {
            hx711DeviceId = nil
            hx711 = nil
        }
        updateStatusText()
    }

    func setUtilitiesForBMP390(input: String) {
        guard let id = bmp390DeviceId else { return }
        connectedDevices[id]?.utilitiesString = input
    }

    func setUtilitiesForHX711(input: String) {
        guard let id = hx711DeviceId else { return }
        connectedDevices[id]?.utilitiesString = input
    }
    
    func setBMP390(input: String) {
        guard let id = bmp390DeviceId else { return }
        connectedDevices[id]?.bmp390String = input
    }
    
    func setHX711(input: String) {
        guard let id = hx711DeviceId else { return }
        connectedDevices[id]?.hx711String = input
    }
}

extension BluetoothDeviceHelper: BTDeviceDelegate {
    func deviceConnected(_ device: BTDevice) {
        // Connection established; UI is driven by ready/notification + our stored models.
        updateStatusText()
    }

    func deviceReady(_ device: BTDevice, supportsBMP390: Bool, supportsHX711: Bool) {
        // No rejection here: user may assign a device to a type and the device might not expose
        // those characteristics. That should just result in no data, not a crash.
        updateStatusText()
    }

    func deviceSerialChanged(_ device: BTDevice, value: String) {
    }

    func deviceDisconnected(_ device: BTDevice) {
        disconnectDevice(id: device.identifier)
    }
}
    
extension BluetoothDeviceHelper {
    static var mock: BluetoothDeviceHelper {
        let helper = BluetoothDeviceHelper()
        // Seed some sample data so previews show non-empty charts.
        let bmp = BMP390()
        bmp.addAltitude(altitude: 100)
        bmp.addAltitude(altitude: 101.5)
        bmp.addAltitude(altitude: 99.2)
        bmp.addTemperature(temperature: 21.0)
        bmp.addTemperature(temperature: 21.3)
        bmp.addTemperature(temperature: 20.9)
        bmp.addPressure(pressure: 101325)
        bmp.addPressure(pressure: 101300)
        bmp.addPressure(pressure: 101340)

        let hx = HX711()
        hx.addAltitude(altitude: 50)
        hx.addAltitude(altitude: 52)
        hx.addAltitude(altitude: 49.5)
        hx.addPressure(pressure: 102000)
        hx.addPressure(pressure: 101950)
        hx.addPressure(pressure: 102020)

        helper.bmp390 = bmp
        helper.hx711 = hx
        return helper
    }
}
