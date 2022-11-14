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

    let networkStateText = BehaviorRelay<String>(value: "")

    let ipAddressText = BehaviorRelay<String>(value: "")

    let peerIPAddressPrefix = BehaviorRelay<String>(value: "")



    private let appModel: AppModelProtocol

    required init(with appModel: AppModelProtocol) {
        self.appModel = appModel
    }

    var showSecondEvent: (() -> ())?

    func configureView() {
        self.refreshIPAddress()
    }

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
        self.refreshIPAddress()
    }

}

private extension FirstScreenViewModel {

    func refreshIPAddress() {
        if let ipAddress = self.appModel.connectivityUtils.getIP() {
            self.networkStateText.accept("IP Address:")
            self.ipAddressText.accept(ipAddress)
            self.peerIPAddressPrefix.accept(self.appModel.connectivityUtils.getPeerIpAddressPrefix(for: ipAddress))
        } else {
            self.networkStateText.accept("IP Address:")
            self.ipAddressText.accept("No network")
        }
    }
}
