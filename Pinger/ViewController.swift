//
//  ViewController.swift
//  Pinger
//
//  Created by Jay Tucker on 1/8/18.
//  Copyright © 2018 Imprivata. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var pingButton: UIButton!
    
    var beaconManager: BeaconManager!
    var bluetoothManager: BluetoothManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        beaconManager = BeaconManager()
        bluetoothManager = BluetoothManager()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ping(_ sender: Any) {
        // singlePing()
        startPingCycle()
    }
    
    private func singlePing() {
        pingButton.isEnabled = false
        beaconManager.startBeacon()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.beaconManager.stopBeacon()
            self.pingButton.isEnabled = true
            self.read(self)
        }
    }
    
    private func startPingCycle() {
        let timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            self.beaconManager.startBeacon()
            Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
                self.beaconManager.stopBeacon()
                self.read(self)
            }
        }
        timer.fire()
    }
    
    @IBAction func read(_ sender: Any) {
        bluetoothManager.go()
    }
    
}

