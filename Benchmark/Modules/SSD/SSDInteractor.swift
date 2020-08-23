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
    
    
    // MARK: - Initializers
    init(presenter: SSDPresenterProtocol) {
        self.presenter = presenter
    }
    
    // MARK: - SSDInteractor methods
}
