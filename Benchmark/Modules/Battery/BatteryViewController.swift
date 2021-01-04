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
    var labelTimer: Timer?
    var startTime = Date()
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US")
        dateFormatter.dateFormat = "HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return dateFormatter
    }()
        
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    @IBOutlet weak var timeLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopButton.isEnabled = false
        timeLabel.stringValue = "00:00:00"
    }
    
    @objc func startCollectionBatteryStats() {
        DispatchQueue.main.async {
            self.timeLabel.stringValue = "00:00:00"
            self.startButton.isEnabled = false
            self.stopButton.isEnabled = true
        }
        
        logger.createLogFileForBattery { (error) in
            // error alert
        }
        
        startTime = Date()
        
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(getBatt), userInfo: nil, repeats: true)
        labelTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimeLabel), userInfo: nil, repeats: true)
        
        updateTimeLabel()
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
    
    @objc func updateTimeLabel() {
        DispatchQueue.main.async {
            
            guard let labelTimer = self.labelTimer else {
                self.timeLabel.stringValue = "The timer is broken"
                return
            }
            
            let time = Date(timeIntervalSince1970: -self.startTime.timeIntervalSince(labelTimer.fireDate))
            self.timeLabel.stringValue = self.dateFormatter.string(from: time)
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
        
        labelTimer?.invalidate()
        labelTimer = nil
    }
}
