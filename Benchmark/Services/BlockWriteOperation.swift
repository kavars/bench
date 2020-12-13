//
//  BlockWriteOperation.swift
//  Benchmark
//
//  Created by Kirill Varshamov on 13.12.2020.
//  Copyright © 2020 Kirill Varshamov. All rights reserved.
//

import Foundation

class BlockWriteOperation: Operation {
    
    var blockCount: Int32
    var uiUpdater: (Int, Int, TimeInterval) -> Void
    
    init(blockCount: Int32, uiUpdater: @escaping (Int, Int, TimeInterval) -> Void) {
        self.blockCount = blockCount
        self.uiUpdater = uiUpdater
    }
    
    override func main() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-dd H-m-ss.SSSS"
        
        let gb = 1024 * 1024 * 1024
        let data = Data(count: gb)
        
        let dirPath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("SSDBlocks")
        
        try? FileManager.default.createDirectory(at: dirPath, withIntermediateDirectories: true, attributes: nil) //
        
        for i in 0..<self.blockCount {
            let startBlock = Date()
            
            if isCancelled {
                break
            }
            
            do {
                try data.write(to: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("SSDBlocks/" + dateFormatter.string(from: Date()) + ".data"))
            } catch {
                print(error.localizedDescription)
            }
            
            let endBlockTime = Date()
            let blockTime = endBlockTime.timeIntervalSince(startBlock)
            
            let result = Int(1024.0 - Double(gb) * blockTime / 1024.0 / 1024.0 + 1024.0)
            
            DispatchQueue.main.async {
                self.uiUpdater(Int(i), result, blockTime)
            }
        }
    }
}
