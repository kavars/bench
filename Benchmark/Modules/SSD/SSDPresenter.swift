//
//  SSDPresenter.swift
//  Benchmark
//
//  Created by Kirill Varshamov on 23.08.2020.
//  Copyright © 2020 Kirill Varshamov. All rights reserved.
//

import Foundation

class SSDPresenter: SSDPresenterProtocol {
    
    // MARK: - Properties
    weak var view: SSDViewProtocol!
    var interactor: SSDInteractorProtocol!
    var router: SSDRouterProtocol!
    
    // MARK: - Initializers
    init(view: SSDViewProtocol) {
        self.view = view
    }
    
    // MARK: - Configure view
    func configureView() {
        
        let freeSpace = Double(interactor.freeSpaceInByte / 1000000000)

        if freeSpace > 70 {
            view.setupSlider(freeSpaceInBytes: freeSpace, sliderStartValue: 70, sliderValueText: "70 GB")
        } else {
            view.setupSlider(freeSpaceInBytes: freeSpace, sliderStartValue: Int(freeSpace) / 2, sliderValueText: "\(Int(freeSpace) / 2) GB")
        }
        
        view.setupDiskSpaceLabels(
            all: spaceFormatter(bytes: interactor.totalSpaceInByte),
            used: spaceFormatter(bytes: interactor.usedSpaceInByte),
            free: spaceFormatter(bytes: interactor.freeSpaceInByte)
        )
        view.setupButtons()
        view.setupInputTextField()
        view.resetUI()
    }
    
    // MARK: - SSDPresenterProtocol methods
    
    func textFieldUpdated(with newValue: String, maxValue: Double) {
        
        guard let newIntValue = Int32(newValue), newIntValue <= Int32(maxValue), newIntValue > 0 else {
            view.createAndShowErrorAlert(with: "Input block size must be more than 0 or less than free space")
            return
        }
        
//        let newLabelValue = "\(newIntValue) GB"
        let newSliderValue = newIntValue
        
//        view.updateSliderTextValue(with: newLabelValue)
        view.updateSliderValue(with: newSliderValue)
        view.blockCount = newIntValue
    }
    
    func sliderMoved(with newValue: Int32) {
        view.updateSliderTextValue(with: "\(newValue) GB")
        view.blockCount = newValue
    }
    
    func startButtonTapped() {
        view.changeUIForStart(blockCount: view.blockCount) // change
        
        interactor.createLogFileForSSD { (error) in
            self.view.createAndShowErrorAlert(with: error)
            
            // delay 0.5 ?
            self.view.resetUI()
            self.view.endWrite()
            
            self.interactor.stopOperation()
        }

        interactor.startWrite(with: view.blockCount)
    }
    
    func stopButtonTapped() {
        interactor.stopOperation()
        
        view.resetUI()
        view.endWrite()
    }
    
    func stopWrite() {
        view.resetUI()
        view.endWrite()
    }
    
    func updateWhileWrite(at index: Int, with result: Int, _ blockCount: Int32) {
        view.updateWriteSpeed("\(result) mb/s")
        view.updateProgress("\(index + 1)/\(blockCount)", Double(index + 1))
    }
    
    // MARK: - Private methods
    
    private func spaceFormatter(bytes: Int64) -> String {
        return ByteCountFormatter.string(fromByteCount: bytes, countStyle: ByteCountFormatter.CountStyle.file)
    }
}
