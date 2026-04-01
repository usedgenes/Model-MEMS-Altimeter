//
//  BMP390.swift
//  CustomAltimeter
//
//  Created by Eugene on 3/24/26.
//
import Foundation
import SwiftUICharts

class BMP390 : ObservableObject {
    @Published var logs = ""
    @Published var deltaTime = "-1"

    @Published var altitude : [LineChartDataPoint] = []
    @Published var temperature : [LineChartDataPoint] = []
    @Published var pressure : [LineChartDataPoint] = []
    
    func addAltitude(altitude: Float) {
        self.altitude.append(LineChartDataPoint(value: Double(altitude), xAxisLabel: " ", description: "Altitude"))
    }
    
    func addTemperature(temperature: Float) {
        self.temperature.append(LineChartDataPoint(value: Double(temperature), xAxisLabel: " ", description: "°C"))
    }
    
    func addPressure(pressure: Float) {
        self.pressure.append(LineChartDataPoint(value: Double(pressure), xAxisLabel: " ", description: "Pascals"))
    }
    
    func getAltitude() -> LineDataSet {
        return LineDataSet(dataPoints: altitude,
                           legendTitle: "m",
                           pointStyle: PointStyle(),
                           style: LineStyle(lineColour: ColourStyle(colour: .red), lineType: .line))
    }
    
    func getTemperature() -> LineDataSet {
        return LineDataSet(dataPoints: temperature,
                           legendTitle: "°C",
                           pointStyle: PointStyle(),
                           style: LineStyle(lineColour: ColourStyle(colour: .green), lineType: .line))
    }
    
    func getPressure() -> LineDataSet {
        return LineDataSet(dataPoints: pressure,
                           legendTitle: "Pascals",
                           pointStyle: PointStyle(),
                           style: LineStyle(lineColour: ColourStyle(colour: .blue), lineType: .line))
    }
    
    func resetBMP390() {
        altitude.removeAll()
        temperature.removeAll()
        pressure.removeAll()
    }
    
    func clearLogs() {
        logs = ""
    }
    
    func reset() {
        resetBMP390()
        clearLogs()
        deltaTime = "-1"
    }
}
