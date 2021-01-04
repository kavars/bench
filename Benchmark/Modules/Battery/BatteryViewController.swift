//
//  BatteryViewController.swift
//  Benchmark
//
//  Created by Kirill Varshamov on 01.12.2020.
//  Copyright © 2020 Kirill Varshamov. All rights reserved.
//

import Cocoa

class BatteryViewController: NSViewController {
    
    var logger: BatteryLogService = LoggerService()
    
    var timer: Timer?
        
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    @IBOutlet weak var timeLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopButton.isEnabled = false
    }
    
    @objc func startCollectionBatteryStats() {
        startButton.isEnabled = false
        stopButton.isEnabled = true
        
        logger.createLogFileForBattery { (error) in
            // error alert
        }

        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(getBatt), userInfo: nil, repeats: true)
    }
    
    @objc func getBatt() {
        DispatchQueue.global(qos: .utility).async {
            guard let data = KABattery.updateStatus(),
                  let temp = data.temperature,
                  let currentCap = data.currentCapacity,
                  let designCap = data.designCapacity,
                  let maxCap = data.maximumCapacity
            else {
                return
            }
            
            self.logger.writeBatteryLog(temp: temp, currentCap: currentCap, maxCap: maxCap, designCap: designCap)
        }

    }
    
    @IBAction func openLogFolder(_ sender: NSButton) {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            NSWorkspace.shared.open(dir)
        }
    }
    
    @IBAction func startCollectionBatteryStats(_ sender: NSButton) {
        startCollectionBatteryStats()
    }
    
    @IBAction func stopCollectionBatteryStats(_ sender: NSButton) {
        stopButton.isEnabled = false
        startButton.isEnabled = true
        
        timer?.invalidate()
        timer = nil
    }
}
