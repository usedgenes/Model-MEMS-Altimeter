//
//  BTUUIDs.swift
//  BLEDemo
//
//  Created by Jindrich Dolezy on 28/11/2018.
//  Copyright © 2018 Dzindra. All rights reserved.
//

import CoreBluetooth


struct BTUUIDs {    
    static let esp32Service = CBUUID(string: "9a8ca9ef-e43f-4157-9fee-c37a3d7dc12d")
        
    static let bmp390UUID = CBUUID(string: "94cbc7dc-ff62-4958-9665-0ed477877581")

    static let utilitiesUUID = CBUUID(string: "fb02a2fa-2a86-4e95-8110-9ded202af76b")
    
    static let hx711UUID = CBUUID(string: "c91b34b8-90f3-4fee-89f7-58c108ab198f")

    
    //    #define UUID_7 "83e6a4bd-8347-409c-87f3-d8c896f15d3d"
    //    #define UUID_8 "680f38b9-6898-40ea-9098-47e30e97dbb5"
}
