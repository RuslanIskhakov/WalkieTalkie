//
//  FirstScreenViewModel.swift
//  BaseMVVMApp
//
//  Created by Ruslan Iskhakov on 09.11.2022.
//

import Foundation

class FirstScreenViewModel: FirstScreenViewModelProtocol {

    private let appModel: AppModelProtocol

    required init(with appModel: AppModelProtocol) {
        self.appModel = appModel
    }

    var showSecondEvent: (() -> ())?

    func showSecondTap() {
        self.showSecondEvent?()
    }

    func startServerTap() {
        self.appModel.serverModel.startServer()
    }
}
