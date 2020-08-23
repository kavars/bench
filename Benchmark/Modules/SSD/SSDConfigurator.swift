//
//  SSDConfigurator.swift
//  Benchmark
//
//  Created by Kirill Varshamov on 23.08.2020.
//  Copyright © 2020 Kirill Varshamov. All rights reserved.
//

import Foundation

class SSDConfigurator: SSDConfiguratorProtocol {
    func configure(with viewController: SSDViewController) {
        let presenter = SSDPresenter(view: viewController)
        let interactor = SSDInteractor(presenter: presenter)
        let router = SSDRouter(viewController: viewController)
        
        viewController.presenter = presenter
        presenter.interactor = interactor
        presenter.router = router
    }
}
