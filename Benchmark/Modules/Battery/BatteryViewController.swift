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
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @objc func startCollectionBatteryStats() {
        logger.createLogFileForBattery { (error) in
            // error alert
        }

        Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(getBatt), userInfo: nil, repeats: true)
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

}
