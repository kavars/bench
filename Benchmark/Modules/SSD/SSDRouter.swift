//
//  SSDRouter.swift
//  Benchmark
//
//  Created by Kirill Varshamov on 23.08.2020.
//  Copyright © 2020 Kirill Varshamov. All rights reserved.
//

import Foundation

class SSDRouter: SSDRouterProtocol {
    // MARK: - Properties
    weak var viewController: SSDViewController!
    
    // MARK: - Initializers
    init(viewController: SSDViewController) {
        self.viewController = viewController
    }
}
