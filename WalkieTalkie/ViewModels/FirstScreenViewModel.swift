//
//  FirstScreenViewModel.swift
//  BaseMVVMApp
//
//  Created by Ruslan Iskhakov on 09.11.2022.
//

import RxSwift
import RxRelay

class FirstScreenViewModel: FirstScreenViewModelProtocol {

    let refreshButtonEnabled = BehaviorRelay<Bool>(value: true)

    let networkStateText = BehaviorRelay<String>(value: "IP address:")

    let ipAddressText = BehaviorRelay<String>(value: "-")



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

    func startClientTap() {
        self.appModel.clientModel.startClient()
    }

    func tryAudioTap() {
        self.appModel.audioModel.tryIt()
    }

    func refreshTap() {

    }

}
