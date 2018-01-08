//
//  BeaconManager.swift
//  Pinger
//
//  Created by Jay Tucker on 1/8/18.
//  Copyright © 2018 Imprivata. All rights reserved.
//

import Foundation
import CoreBluetooth
import CoreLocation

final class BeaconManager: NSObject {
    
    private let proximityUUID = UUID(uuidString: "0130C53E-97C1-421A-81C0-FC8F453295AD")!
    private let major: CLBeaconMajorValue = 123
    private let minor: CLBeaconMinorValue = 456
    private let identifier = "com.imprivata.pinger"
    
    private var beaconRegion: CLBeaconRegion!
    private var peripheralManager: CBPeripheralManager!
    
    private var isPoweredOn = false
    private var isBeaconing = false
    
    override init() {
        super.init()
        beaconRegion = CLBeaconRegion(proximityUUID: proximityUUID, major: major, minor: minor, identifier: identifier)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    func startBeacon() {
        log("startBeacon")
        guard isPoweredOn else {
            log("not powered on")
            return
        }
        guard !isBeaconing else {
            log("already running")
            return
        }
        let beaconPeripheralData = (beaconRegion.peripheralData(withMeasuredPower: nil) as NSDictionary) as! [String:AnyObject]
        peripheralManager.startAdvertising(beaconPeripheralData)
    }
    
    func stopBeacon() {
        log("stopBeacon")
        guard beaconRegion != nil && peripheralManager != nil else {
            log("already stopped")
            return
        }
        peripheralManager.stopAdvertising()
        isBeaconing = false
    }
    
}

extension BeaconManager: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        log("peripheralManagerDidUpdateState")
        if peripheral.state == .poweredOn {
            log("poweredOn")
            isPoweredOn = true
        } else if peripheral.state == .poweredOff {
            log("poweredOff")
            isPoweredOn = false
            stopBeacon()
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        let message = "peripheralManagerDidStartAdvertising " +  (error == nil ? "ok" : "error " + error!.localizedDescription)
        log(message)
        isBeaconing = true
    }
    
}
