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
    }
    
    // MARK: - SSDPresenterProtocol methods
    
    func textFieldUpdated(with newValue: String, maxValue: Double) {
        
        guard let newIntValue = Int32(newValue), newIntValue <= Int32(maxValue), newIntValue > 0 else {
            view.createAndActivateAlert()
            return
        }
        
        let newLabelValue = "\(newIntValue) GB"
        let newSliderValue = newIntValue
        
        view.updateSliderTextValue(with: newLabelValue)
        view.updateSliderValue(with: newSliderValue)
    }
    
    func sliderMoved(with newValue: Int32) {
        view.updateSliderTextValue(with: "\(newValue) GB")
    }
    
    // MARK: - Private methods
    
    func spaceFormatter(bytes: Int64) -> String {
        return ByteCountFormatter.string(fromByteCount: bytes, countStyle: ByteCountFormatter.CountStyle.file)
    }
}
