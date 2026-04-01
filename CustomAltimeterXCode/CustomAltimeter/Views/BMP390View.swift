import SwiftUI

struct BMP390View: View {
    @EnvironmentObject var bluetoothDevice: BluetoothDeviceHelper
    
    var body: some View {
        Text("BMP390 Altitude")
            .font(.title)
            .fontWeight(.bold)
        
        if let bmp390 = bluetoothDevice.bmp390 {
            BMP390ConnectedView(bmp390: bmp390)
                .environmentObject(bluetoothDevice)
        } else {
            Text("No BMP390 devices connected.")
                .padding()
        }
    }
}


struct BMP390ConnectedView: View {
    @ObservedObject var bmp390: BMP390
    @EnvironmentObject var bluetoothDevice: BluetoothDeviceHelper
    @State private var getData = false
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                GeometryReader { geometry in
                    HStack(spacing: 10) {
                        Button(action: {
                            if !getData {
                                bluetoothDevice.setUtilitiesForBMP390(input: "BMP390 Get")
                            } else {
                                bluetoothDevice.setUtilitiesForBMP390(input: "BMP390 Stop")
                            }
                            getData.toggle()
                        }) {
                            Text(!getData ? "Get Data" : "Stop")
                                .font(.title2)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                        .buttonStyle(SensorToolbarButtonStyle(isActive: getData))
                        .frame(width: (geometry.size.width - 20) * 0.5)
                        
                        Button(action: {
                            bmp390.resetBMP390()
                        }) {
                            Text("Clear")
                                .font(.title2)
                        }
                        .buttonStyle(SensorToolbarButtonStyle())
                        .frame(width: (geometry.size.width - 20) * 0.25)
                        
                        Button(action: {
                            bluetoothDevice.setBMP390(input: "Tare")
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
                bluetoothDevice.setUtilitiesForBMP390(input: "Altimeter Stop")
            }
            Divider()
                .frame(maxWidth: .infinity)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let bmp = bluetoothDevice.bmp390 {
                        BMP390SingleGraphsView(bmp: bmp)
                            .padding(.bottom, 16)
                    }
                }
                .padding(.top, 20)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
}

struct BMP390View_Previews: PreviewProvider {
    static var previews: some View {
        BMP390View()
            .environmentObject(BluetoothDeviceHelper.mock)
    }
}

private struct BMP390SingleGraphsView: View {
    @ObservedObject var bmp: BMP390
    
    var body: some View {
        VStack(alignment: .leading) {
            ChartStyle().getGraph(datasets: bmp.getAltitude(), colour: .red)
        }
    }
}
