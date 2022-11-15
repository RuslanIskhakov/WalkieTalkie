//
//  FirstScreenViewModel.swift
//  BaseMVVMApp
//
//  Created by Ruslan Iskhakov on 09.11.2022.
//

import RxSwift
import RxRelay

class FirstScreenViewModel: BaseViewModel, FirstScreenViewModelProtocol {

    let refreshButtonEnabled = BehaviorRelay<Bool>(value: true)

    let ipAddressText = BehaviorRelay<String>(value: "IP-адрес:")

    let peerIPAddressPrefix = BehaviorRelay<String>(value: "")

    let portNumberText = BehaviorRelay<String>(value: "")

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

    func refreshTap() {
        self.refreshIPAddress()
    }

    func setPeerIPAddress(_ ipAddress: String) {
        var settings = self.appModel.appSettingsModel
        settings.peerIPAddress = ipAddress
    }

    func setPortNumber(_ poertNumber: String) {
        var settings = self.appModel.appSettingsModel
        settings.portNumber = poertNumber
    }

}

private extension FirstScreenViewModel {

    func refreshIPAddress() {
        if let ipAddress = self.appModel.connectivityUtils.getIP() {
            self.ipAddressText.accept(ipAddress)
            let peerPrefix = self.appModel.connectivityUtils.getPeerIpAddressPrefix(for: ipAddress)
            let peerIPAddress = self.appModel.appSettingsModel.peerIPAddress
            self.peerIPAddressPrefix.accept(
                peerIPAddress.starts(with: peerPrefix) ?
                peerIPAddress :
                peerPrefix
            )
        } else {
            self.ipAddressText.accept("No network")
        }

        self.portNumberText.accept(self.appModel.appSettingsModel.portNumber)
    }
}
