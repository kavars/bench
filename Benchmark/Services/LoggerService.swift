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
}

// MARK: - SSDLogService
extension LoggerService: SSDLogService {
    
    /// Create log file for write session
    /// - Parameter failure: Error handler
    func createLogFileForSSD(failure: @escaping (String) -> Void) {
        DispatchQueue.global(qos: .utility).async {
                        
            self.dateFormatter.dateFormat = "HH-mm-ss"
            
            self.logFileName = "ssd_test+\(self.dateFormatter.string(from: Date())).csv"
            
            let text = "Block;Speed;Time\n"
            
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                
                let fileURL = dir.appendingPathComponent(self.logFileName)
                
                do {
                    try text.write(to: fileURL, atomically: false, encoding: .utf8)
                } catch {
                    failure("\(error.localizedDescription)\nCan't create log file")
                }
            }
        }
    }
    
    /// Write log to write session's log file
    /// - Parameters:
    ///   - index: Row index in log file
    ///   - speed: Write speed
    ///   - time: Write time
    func writeSSDLog(index: Int, speed: Int, time: Double) {
        DispatchQueue.global(qos: .utility).async {
            let text = "\(index);\(speed);\(time)\n"
            
            let stringData = text.data(using: .utf8)!
            
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
}

// MARK: - BatteryLogService
extension LoggerService: BatteryLogService {
    
    /// Create log file for battery stats
    /// - Parameter failure: Error handler
    func createLogFileForBattery(failure: @escaping (String) -> Void) {
        dateFormatter.dateFormat = "HH-mm-ss"

        logFileName = "battery_test+\(dateFormatter.string(from: Date())).csv"
        
        let text = "Time;Temperature;Current Capacity;Maximum capacity;Design capacity\n"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(logFileName)
            
            do {
                try text.write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {print(error.localizedDescription)}
        }
    }
    
    /// Write log to battery's log file
    /// - Parameters:
    ///   - temp: Battery's temperature
    ///   - currentCap: Battery's current capacity
    ///   - maxCap: Battery's maximum capacity
    ///   - designCap: Battery's design capacity
    func writeBatteryLog(temp: NSNumber, currentCap: NSNumber, maxCap: NSNumber, designCap: NSNumber) {
        
        self.dateFormatter.dateFormat = "HH:mm:ss"
        
        let text = self.dateFormatter.string(from: Date()) + ";\(temp);\(currentCap);\(maxCap);\(designCap)\n"
        
        let stringData = text.data(using: .utf8)!

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
