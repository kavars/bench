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
        
        let freeSpace = DiskStatus.freeDiskSpaceInBytes / 1000000000
        
        if freeSpace > 70 {
            view.setupSlider(freeSpaceInBytes: freeSpace, sliderStartValue: 70)
        } else {
            view.setupSlider(freeSpaceInBytes: freeSpace, sliderStartValue: Int(freeSpace) / 2)
        }
        
        
        view.setupDiskSpaceLabels(all: DiskStatus.totalDiskSpace, used: DiskStatus.usedDiskSpace, free: DiskStatus.freeDiskSpace)
        view.setupButtons()
        view.setupInputTextField()
    }
    
    // MARK: - SSDPresenter methods
}
