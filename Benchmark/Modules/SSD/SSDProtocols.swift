//
//  SSDProtocols.swift
//  Benchmark
//
//  Created by Kirill Varshamov on 23.08.2020.
//  Copyright © 2020 Kirill Varshamov. All rights reserved.
//

import Foundation

// MARK: - View protocol
protocol SSDViewProtocol: class {
    func setupSlider(freeSpaceInBytes: Int64, sliderStartValue: Int)
    func setupDiskSpaceLabels(all: String, used: String, free: String)
    func setupButtons()
    func setupInputTextField()
}

// MARK: - Interactor protocol
protocol SSDInteractorProtocol: class {
    
}

// MARK: - Presenter protocol
protocol SSDPresenterProtocol: class {
    var router: SSDRouterProtocol! { set get }
    
    func configureView()
}

// MARK: - Configurator protocol
protocol SSDConfiguratorProtocol: class {
    func configure(with viewController: SSDViewController)
}

// MARK: - Router protocol
protocol SSDRouterProtocol: class {
    
}
