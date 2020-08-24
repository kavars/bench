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
    }
    
    // MARK: - SSDInteractor methods
}
