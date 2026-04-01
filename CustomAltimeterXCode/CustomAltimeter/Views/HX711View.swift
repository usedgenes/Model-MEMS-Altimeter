//
//  HX711View.swift
//  CustomAltimeter
//
//  Created by Eugene on 3/25/26.
//
import SwiftUI

struct HX711View: View {
    @EnvironmentObject var bluetoothDevice: BluetoothDeviceHelper

    var body: some View {
        Text("HX711 Altitude")
            .font(.title)
            .fontWeight(.bold)

        if let hx = bluetoothDevice.hx711 {
            HX711ConnectedView(hx: hx)
                .environmentObject(bluetoothDevice)
        } else {
            Text("No HX711 devices connected.")
                .padding()
        }
    }
}

private struct HX711ConnectedView: View {
    @ObservedObject var hx: HX711
    @EnvironmentObject var bluetoothDevice: BluetoothDeviceHelper
    @State private var getData = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                GeometryReader { geometry in
                    HStack(spacing: 10) {
                        Button(action: {
                            if !getData {
                                bluetoothDevice.setUtilitiesForHX711(input: "HX711 Get")
                            } else {
                                bluetoothDevice.setUtilitiesForHX711(input: "HX711 Stop")
                            }
                            getData.toggle()
                        }) {
                            Text(!getData ? (hx.doneCalibrating ? "Get Data" : "Calibrating...") : "Stop")
                                .font(.title2)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                        .buttonStyle(SensorToolbarButtonStyle(isActive: getData))
                        .frame(width: (geometry.size.width - 20) * 0.5)

                        Button(action: {
                            hx.resetHX711()
                        }) {
                            Text("Clear")
                                .font(.title2)
                        }
                        .buttonStyle(SensorToolbarButtonStyle())
                        .frame(width: (geometry.size.width - 20) * 0.25)

                        Button(action: {
                            bluetoothDevice.setHX711(input: "Tare")
                        }) {
                            Text("Tare")
                                .font(.title2)
                        }
                        .buttonStyle(SensorToolbarButtonStyle())
                        .frame(width: (geometry.size.width - 20) * 0.25)
                    }
                }
                .frame(height: 70)

            }
            .frame(maxWidth: .infinity)
            .onDisappear {
                bluetoothDevice.setUtilitiesForBMP390(input: "HX711 Stop")
            }

            Divider()
                .frame(maxWidth: .infinity)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HX711SingleGraphsView(hx: hx)
                        .padding(.bottom, 16)
                }
                .padding(.top, 20)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct HX711View_Previews: PreviewProvider {
    static var previews: some View {
        HX711View()
            .environmentObject(BluetoothDeviceHelper.mock)
    }
}

private struct HX711SingleGraphsView: View {
    @ObservedObject var hx: HX711

    var body: some View {
        VStack(alignment: .leading) {
            ChartStyle().getGraph(datasets: hx.getAltitude(), colour: .red)

        }
    }
}

