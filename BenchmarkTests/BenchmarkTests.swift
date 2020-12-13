//
//  BenchmarkTests.swift
//  BenchmarkTests
//
//  Created by Kirill Varshamov on 23.08.2020.
//  Copyright © 2020 Kirill Varshamov. All rights reserved.
//

import XCTest
@testable import Benchmark

class BenchmarkTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        let data = Data(count: 4*1024*1024*1024)
        

        self.measure {
            do {
                try data.write(to: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("test.data"))
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }

}
