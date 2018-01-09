//
//  BluetoothManager.swift
//  Pinger
//
//  Created by Jay Tucker on 1/9/18.
//  Copyright © 2018 Imprivata. All rights reserved.
//

import Foundation
import CoreBluetooth

final class BluetoothManager: NSObject {
    
    private let serviceUUID        = CBUUID(string: "3025E7A9-CC24-4B7C-B806-0F674D07E46C")
    private let characteristicUUID = CBUUID(string: "9476292B-5E5A-4CD4-BD3E-9B1E7B4DB12E")

    private let timeoutInSecs = 5.0
    
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    private var characteristic: CBCharacteristic!
    
    private var isPoweredOn = false
    private var scanTimer: Timer!
    private var isBusy = false
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate:self, queue:nil)
    }
    
    func go() {
        log("go")
        guard isPoweredOn else {
            log("not powered on")
            return
        }
        guard !isBusy else {
            log("busy, ignoring request")
            return
        }
        isBusy = true
        startScanForPeripheral(serviceUuid: serviceUUID)
    }
    
    private func startScanForPeripheral(serviceUuid: CBUUID) {
        log("startScanForPeripheral")
        centralManager.stopScan()
        scanTimer = Timer.scheduledTimer(timeInterval: timeoutInSecs, target: self, selector: #selector(timeout), userInfo: nil, repeats: false)
        centralManager.scanForPeripherals(withServices: [serviceUuid], options: nil)
    }
    
    // can't be private because called by timer
    @objc func timeout() {
        log("timed out")
        centralManager.stopScan()
        isBusy = false
    }
    
    private func disconnect() {
        log("disconnect")
        centralManager.cancelPeripheralConnection(peripheral)
        peripheral = nil
        characteristic = nil
        isBusy = false
    }
    
}

extension BluetoothManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var caseString: String!
        switch central.state {
        case .unknown:
            caseString = "unknown"
        case .resetting:
            caseString = "resetting"
        case .unsupported:
            caseString = "unsupported"
        case .unauthorized:
            caseString = "unauthorized"
        case .poweredOff:
            caseString = "poweredOff"
        case .poweredOn:
            caseString = "poweredOn"
        }
        log("centralManagerDidUpdateState \(caseString!)")
        isPoweredOn = centralManager.state == .poweredOn
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        log("centralManager didDiscoverPeripheral")
        scanTimer.invalidate()
        centralManager.stopScan()
        self.peripheral = peripheral
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        log("centralManager didConnectPeripheral")
        self.peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }
    
}

extension BluetoothManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        let message = "peripheral didDiscoverServices " + (error == nil ? "ok" :  ("error " + error!.localizedDescription))
        log(message)
        guard error == nil else { return }
        for service in peripheral.services! {
            log("service \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        let message = "peripheral didDiscoverCharacteristicsFor service " + (error == nil ? "\(service.uuid) ok" :  ("error " + error!.localizedDescription))
        log(message)
        guard error == nil else { return }
        for characteristic in service.characteristics! {
            log("characteristic \(characteristic.uuid)")
            if characteristic.uuid == characteristicUUID {
                self.characteristic = characteristic
                peripheral.readValue(for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let message = "peripheral didUpdateValueFor characteristic " + (error == nil ? "\(characteristic.uuid) ok" :  ("error " + error!.localizedDescription))
        log(message)
        defer {
            disconnect()
        }
        guard error == nil else { return }
        let response = String(data: characteristic.value!, encoding: String.Encoding.utf8)!
        log("\(response)")
    }
    
}
