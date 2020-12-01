//
//  BatteryViewController.swift
//  Benchmark
//
//  Created by Kirill Varshamov on 01.12.2020.
//  Copyright © 2020 Kirill Varshamov. All rights reserved.
//

import Cocoa

class BatteryViewController: NSViewController {
    
    var file = ""
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US")
        return dateFormatter
    }()
        
    override func viewDidLoad() {
        dateFormatter.dateFormat = "HH-mm-ss"
        file = "battery_test+\(dateFormatter.string(from: Date())).csv"
        dateFormatter.dateFormat = "HH:mm:ss"

        Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(getBatt), userInfo: nil, repeats: true)

        let text = "Time;Temperature;Current Capacity;Maximum capacity;Design capacity\n"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(file)
            
            do {
                try text.write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {print(error.localizedDescription)}
        }
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
            
            let text = self.dateFormatter.string(from: Date()) + ";\(temp);\(currentCap);\(maxCap);\(designCap)\n"
            
            let stringData = text.data(using: .utf8)!

            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                
                let fileURL = dir.appendingPathComponent(self.file)
                
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(stringData)
                        fileHandle.closeFile()
                    }
                }
            }
        }

    }

}
