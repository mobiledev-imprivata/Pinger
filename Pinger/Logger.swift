//
//  Logger.swift
//  Pinger
//
//  Created by Jay Tucker on 1/8/18.
//  Copyright © 2018 Imprivata. All rights reserved.
//

import Foundation

enum Component: String {
    case app, vc, beac, btle
}

var dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "HH:mm:ss.SSS"
    return df
}()

func log(_ component: Component, _ message: String) {
    let timestamp = dateFormatter.string(from: Date())
    print("[\(timestamp)] \(component.rawValue.uppercased().padding(toLength: 4, withPad: " ", startingAt: 0)) \(message)")
}
