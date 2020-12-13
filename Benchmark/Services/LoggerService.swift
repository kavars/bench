//
//  LoggerService.swift
//  Benchmark
//
//  Created by Kirill Varshamov on 13.12.2020.
//  Copyright © 2020 Kirill Varshamov. All rights reserved.
//

import Foundation

// MARK: - Protocols

/// Base logger service protocol
protocol LogService: class {
    
    /// Log file name
    var logFileName: String { get }
}


/// Logger service protocol for SSD module
protocol SSDLogService: LogService {
    
    /// Create log file for write session
    /// - Parameter failure: Error handler
    func createLogFileForSSD(failure: @escaping (String) -> Void)
    
    /// Write log to write session's log file
    /// - Parameters:
    ///   - index: Row index in log file
    ///   - speed: Write speed
    ///   - time: Write time
    func writeSSDLog(index: Int, speed: Int, time: Double)
}


/// Logger service protocol for Battery module
protocol BatteryLogService: LogService {
    
    /// Create log file for battery stats
    /// - Parameter failure: Error handler
    func createLogFileForBattery(failure: @escaping (String) -> Void)
        
    /// Write log to battery's log file
    /// - Parameters:
    ///   - temp: Battery's temperature
    ///   - currentCap: Battery's current capacity
    ///   - maxCap: Battery's maximum capacity
    ///   - designCap: Battery's design capacity
    func writeBatteryLog(temp: NSNumber, currentCap: NSNumber, maxCap: NSNumber, designCap: NSNumber)
}

// MARK: - Logger Service

/// Logger Service
class LoggerService {
    
    /// Log file name
    var logFileName = ""
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US")
        return dateFormatter
    }()
    
    
    /// Create log file
    /// - Parameters:
    ///   - structure: CSV log structure
    ///   - failure: Failure handler
    private func createLogFile(with structure: String, failure: @escaping (String) -> Void) {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(self.logFileName)
            
            do {
                try structure.write(to: fileURL, atomically: false, encoding: .utf8)
            } catch {
                failure("\(error.localizedDescription)\n\nCan't create log file")
            }
        }
    }
    
    
    /// Write log
    /// - Parameter data: Log data in CSV style
    private func writeLog(with data: String) {
        guard let stringData = data.data(using: .utf8) else {
            return
        }
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(self.logFileName)
            
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

// MARK: - SSDLogService
extension LoggerService: SSDLogService {
    
    /// Create log file for write session
    /// - Parameter failure: Error handler
    func createLogFileForSSD(failure: @escaping (String) -> Void) {
        DispatchQueue.global(qos: .utility).async {
                        
            self.dateFormatter.dateFormat = "HH-mm-ss"
            
            self.logFileName = "ssd_test+\(self.dateFormatter.string(from: Date())).csv"
            
            let structure = "Block;Speed;Time\n"
            
            self.createLogFile(with: structure, failure: failure)
        }
    }
    
    /// Write log to write session's log file
    /// - Parameters:
    ///   - index: Row index in log file
    ///   - speed: Write speed
    ///   - time: Write time
    func writeSSDLog(index: Int, speed: Int, time: Double) {
        DispatchQueue.global(qos: .utility).async {
            let logData = "\(index);\(speed);\(time)\n"
            
            self.writeLog(with: logData)
        }
    }
}

// MARK: - BatteryLogService
extension LoggerService: BatteryLogService {
    
    /// Create log file for battery stats
    /// - Parameter failure: Error handler
    func createLogFileForBattery(failure: @escaping (String) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            self.dateFormatter.dateFormat = "HH-mm-ss"

            self.logFileName = "battery_test+\(self.dateFormatter.string(from: Date())).csv"
            
            let structure = "Time;Temperature;Current Capacity;Maximum capacity;Design capacity\n"
            
            self.createLogFile(with: structure, failure: failure)
        }
    }
    
    /// Write log to battery's log file
    /// - Parameters:
    ///   - temp: Battery's temperature
    ///   - currentCap: Battery's current capacity
    ///   - maxCap: Battery's maximum capacity
    ///   - designCap: Battery's design capacity
    func writeBatteryLog(temp: NSNumber, currentCap: NSNumber, maxCap: NSNumber, designCap: NSNumber) {
        
        DispatchQueue.global(qos: .utility).async {
            self.dateFormatter.dateFormat = "HH:mm:ss"
            
            let logData = self.dateFormatter.string(from: Date()) + ";\(temp);\(currentCap);\(maxCap);\(designCap)\n"
            
            self.writeLog(with: logData)
        }
    }
}
