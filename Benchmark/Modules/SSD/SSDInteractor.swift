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

    lazy var logger: SSDLogService = LoggerService()
    
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
    
    func startWrite(with blockCount: Int32) {
        let blockWriteOperation = BlockWriteOperation(blockCount: blockCount) { (index, result, blockTime) in
            
            self.logger.writeSSDLog(index: Int(index) + 1, speed: result, time: blockTime)
            
            self.presenter.updateWhileWrite(at: index, with: result, blockCount)
        }
        
        blockWriteOperation.completionBlock = {
            if !blockWriteOperation.isCancelled {
                // move delay to view layer
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.presenter.stopWrite()
                }
            }
            self.presenter.configureView()

        }
        
        opQueue.addOperation(blockWriteOperation)
    }
}
