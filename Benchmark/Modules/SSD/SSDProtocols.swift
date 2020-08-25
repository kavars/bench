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
    var blockCount: Int32 { set get }
    
    func setupSlider(freeSpaceInBytes: Double, sliderStartValue: Int, sliderValueText: String)
    func setupDiskSpaceLabels(all: String, used: String, free: String)
    func setupButtons()
    func setupInputTextField()
    
    func updateSliderTextValue(with textValue: String)
    func updateSliderValue(with intValue: Int32)
    func createAndActivateAlert()
}

// MARK: - Interactor protocol
protocol SSDInteractorProtocol: class {
    
    var totalSpaceInByte: Int64 { get }
    var usedSpaceInByte: Int64 { get }
    var freeSpaceInByte: Int64 { get }
}

// MARK: - Presenter protocol
protocol SSDPresenterProtocol: class {
    var router: SSDRouterProtocol! { set get }
    
    func configureView()
    
    func textFieldUpdated(with newValue: String, maxValue: Double)
    func sliderMoved(with newValue: Int32)
}

// MARK: - Configurator protocol
protocol SSDConfiguratorProtocol: class {
    func configure(with viewController: SSDViewController)
}

// MARK: - Router protocol
protocol SSDRouterProtocol: class {
    
}
