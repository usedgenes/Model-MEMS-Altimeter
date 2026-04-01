//
//  HomeScreenView.swift
//  CustomAltimeter
//
//  Created by Eugene on 3/24/26.
//

import SwiftUI
import SwiftUICharts

struct HomeScreenView: View {
    @EnvironmentObject var bluetoothDevice : BluetoothDeviceHelper
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Bluetooth")) {
                    NavigationLink("Connect Devices", destination: BluetoothConnectView())
                }
                Section(header: Text("BMP390")) {
                    BMP390View()
                }
                Section(header: Text("HX711")) {
                    HX711View()
                }
            }
            .navigationBarTitle("Custom Altimeter")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreenView()
            .environmentObject(BluetoothDeviceHelper.mock)
            .environmentObject(BluetoothManagerHelper())
    }
}

extension View {
    func hideKeyboardWhenTappedAround() -> some View  {
        return self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                            to: nil, from: nil, for: nil)
        }
    }
}
