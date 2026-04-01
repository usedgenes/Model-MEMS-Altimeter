//
//  HX711.swift
//  CustomAltimeter
//
//  Created by Eugene on 3/25/26.
//
//
import Foundation
import SwiftUICharts

class HX711 : ObservableObject {
    @Published var logs = ""
    @Published var deltaTime = "-1"

    @Published var altitude : [LineChartDataPoint] = []
    @Published var pressure : [LineChartDataPoint] = []
    @Published var doneCalibrating = false

    func addAltitude(altitude: Float) {
        self.altitude.append(LineChartDataPoint(value: Double(altitude), xAxisLabel: " ", description: "Altitude"))
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
    
    func getPressure() -> LineDataSet {
        return LineDataSet(dataPoints: pressure,
                           legendTitle: "Pascals",
                           pointStyle: PointStyle(),
                           style: LineStyle(lineColour: ColourStyle(colour: .blue), lineType: .line))
    }
    
    func resetHX711() {
        altitude.removeAll()
        pressure.removeAll()
    }
    
    func clearLogs() {
        logs = ""
    }
    
    func reset() {
        resetHX711()
        clearLogs()
        deltaTime = "-1"
    }
    
    func calibrationDone() {
        doneCalibrating = true
    }
    
    func isDoneCalibrating() -> Bool {
        return doneCalibrating
    }
}

