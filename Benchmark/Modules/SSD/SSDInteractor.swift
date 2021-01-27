//
//  SSDInteractor.swift
//  Benchmark
//
//  Created by Kirill Varshamov on 23.08.2020.
//  Copyright © 2020 Kirill Varshamov. All rights reserved.
//

import Foundation

class SSDInteractor: SSDInteractorProtocol {
    // MARK: - Properties
    weak var presenter: SSDPresenterProtocol!
    let opQueue = OperationQueue()
    
    var blockCount: Int32 = 1

    lazy var logger: SSDLogService = LoggerService()
    
    var currentLogName: String {
        return logger.logFileName
    }
    
    var totalSpaceInByte: Int64 {
        get {
            return DiskStatus.totalDiskSpaceInBytes
        }
    }
    
    var usedSpaceInByte: Int64 {
        get {
            return DiskStatus.usedDiskSpaceInBytes
        }
    }
    
    var freeSpaceInByte: Int64 {
        get {
            return DiskStatus.freeDiskSpaceInBytes
        }
    }
    
    // MARK: - Initializers
    init(presenter: SSDPresenterProtocol) {
        self.presenter = presenter
        
        opQueue.qualityOfService = .userInteractive
    }
    
    // MARK: - SSDInteractor methods
    
    func createLogFileForSSD(failure: @escaping (String) -> Void) {
        logger.createLogFileForSSD(failure: failure)
    }
    
    func stopOperation() {
        opQueue.cancelAllOperations()
    }
    
    func startWrite() {
        let blockWriteOperation = BlockWriteOperation(blockCount: blockCount) { (index, result, blockTime) in
            
            self.logger.writeSSDLog(index: Int(index) + 1, speed: result, time: blockTime)
            
            self.presenter.updateWhileWrite(at: index, with: result, self.blockCount)
        }
        
        blockWriteOperation.completionBlock = {
            if !blockWriteOperation.isCancelled {
                // move delay to view layer
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.presenter.stopWrite()
                }
            }
            self.presenter.updateUI()

        }
        
        opQueue.addOperation(blockWriteOperation)
    }
    
    func moveLogFile(to url: URL) {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

            let fileURL = dir.appendingPathComponent(logger.logFileName)

            do {
                _ = try FileManager.default.replaceItemAt(url, withItemAt: fileURL)
            } catch {
                presenter.showAlert(with: error.localizedDescription + "\n\nYou can find log at ~/Library/Containers/Benchmark/data/Documents/")
            }
        }
    }
}
