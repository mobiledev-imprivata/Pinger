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
    
    let beaconManager = BeaconManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func ping(_ sender: Any) {
        pingButton.isEnabled = false
        beaconManager.startBeacon()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.beaconManager.stopBeacon()
            self.pingButton.isEnabled = true
        }
    }
    
    @IBAction func read(_ sender: Any) {
    }
    
}

