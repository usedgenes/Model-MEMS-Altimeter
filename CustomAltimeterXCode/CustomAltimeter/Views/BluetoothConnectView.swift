//
//  SwiftUIView.swift
//  ESP 32 Interface
//
//  Created by Eugene on 7/24/24.
//

import SwiftUI
import CoreBluetooth


struct BluetoothConnectView: View {
    @EnvironmentObject var bluetoothDevice: BluetoothDeviceHelper
    @EnvironmentObject var bluetoothManagerHelper: BluetoothManagerHelper
    @State private var showBluetoothAlert: Bool = false
    @State var LED_On = false

    /// Scan results plus any connected peripherals (connected devices often stop advertising and won’t be rediscovered).
    private var displayedDevices: [BTDevice] {
        var byId: [UUID: BTDevice] = [:]
        for d in bluetoothManagerHelper.devices {
            byId[d.identifier] = d
        }
        for (id, d) in bluetoothDevice.connectedDevices {
            if byId[id] == nil {
                byId[id] = d
            }
        }
        return byId.values.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    var body: some View {
        Text("Bluetooth")
            .font(.title)
            .fontWeight(.bold)
        Divider()
        HStack {
            Spacer()
            Button(action: {
                bluetoothDevice.refresh()
            }) {
                Text("Refresh")
                    .font(.title2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
            .background(Color("Light Gray"))
            .cornerRadius(10)
            Spacer()
            Button(action: {
                if bluetoothDevice.isConnected {
                    bluetoothDevice.disconnectAll()
                } else {
                    showBluetoothAlert = true
                    
                }
            }) {
                Text("Disconnect")
                    .font(.title2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
            .background(Color("Light Gray"))
            .cornerRadius(10)
            Spacer()
        }                                      
        .alert(isPresented: $showBluetoothAlert) {
            Alert(
                title: Text("No Bluetooth Device Connected"),
                message: Text("Please select a device to connect to")
            )
        }
        Divider()
        VStack {
            HStack{
                Text("Status:")
                    .font(.title2)
                Spacer()
                Text(bluetoothDevice.statusText)
                    .font(.title2)
            }
            .padding()
            
            HStack{
                Text("Device State:")
                    .font(.title2)
                
                Spacer()
                Text(bluetoothDevice.isConnected ? "Connected" : "Not connected")
                    .font(.title2)
                
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        Divider()
        List {
            ForEach(displayedDevices, id: \.identifier) { device in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(device.name)
                            .font(.title3)
                        let id = device.identifier
                        if bluetoothDevice.bmp390DeviceId == id && bluetoothDevice.hx711DeviceId == id {
                            Text("Assigned: BMP390 + HX711")
                                .font(.subheadline)
                        } else if bluetoothDevice.bmp390DeviceId == id {
                            Text("Assigned: BMP390")
                                .font(.subheadline)
                        } else if bluetoothDevice.hx711DeviceId == id {
                            Text("Assigned: HX711")
                                .font(.subheadline)
                        } else {
                            Text("Not assigned")
                                .font(.subheadline)
                        }
                    }
                    Spacer()

                    VStack(spacing: 8) {
                        Button(action: {
                            bluetoothDevice.connect(device: device, as: .bmp390)
                        }) {
                            Text("Use BMP390")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)

                        Button(action: {
                            bluetoothDevice.connect(device: device, as: .hx711)
                        }) {
                            Text("Use HX711")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .contentShape(Rectangle())
                
            }
        }
        
    }
}


struct BluetoothConnectView_Previews: PreviewProvider {
    static var previews: some View {
        BluetoothConnectView()
            .environmentObject(BluetoothDeviceHelper())
            .environmentObject(BluetoothManagerHelper())
    }
}
