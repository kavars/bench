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
//    var blockCount: Int32 { set get }
    
    func setupSlider(freeSpaceInBytes: Double)
    func updateSlider(freeSpaceInBytes: Double)
    func setupDiskSpaceLabels(all: String, used: String, free: String)
    func setupButtons()
    func setupInputTextField()
    
    func updateSliderTextValue(with textValue: String)
    func updateSliderValue(with intValue: Int32)
    func createAndShowErrorAlert(with description: String)
    func checkBlocksFolder()
    func resetUI()
    func endWrite()
    
    func changeUIForStart(blockCount: Int32)
    
    func updateWriteSpeed(_ speed: String)
    func updateProgress(_ label: String, _ indicator: Double)
}

// MARK: - Interactor protocol
protocol SSDInteractorProtocol: class {
    var blockCount: Int32 { set get }
    var currentLogName: String { get }
    
    var totalSpaceInByte: Int64 { get }
    var usedSpaceInByte: Int64 { get }
    var freeSpaceInByte: Int64 { get }
    
    func createLogFileForSSD(failure: @escaping (String) -> Void)
    func stopOperation()
    func startWrite()
    
    func moveLogFile(to url: URL)
}

// MARK: - Presenter protocol
protocol SSDPresenterProtocol: class {
    var router: SSDRouterProtocol! { set get }
    var currentLogName: String { get }
    
    func configureView()
    
    func textFieldUpdated(with newValue: String, maxValue: Double)
    func sliderMoved(with newValue: Int32)
    
    func startButtonTapped()
    func stopButtonTapped()
    
    func stopWrite()
    
    func updateWhileWrite(at index: Int, with result: Int, _ blockCount: Int32)
    
    func updateUI()
    
    func showAlert(with message: String)
    func moveLogFile(to url: URL)
}

// MARK: - Configurator protocol
protocol SSDConfiguratorProtocol: class {
    func configure(with viewController: SSDViewController)
}

// MARK: - Router protocol
protocol SSDRouterProtocol: class {
    
}
