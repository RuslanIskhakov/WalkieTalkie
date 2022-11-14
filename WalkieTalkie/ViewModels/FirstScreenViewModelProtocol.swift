//
//  FirstScreenViewModelProtocol.swift
//  BaseMVVMApp
//
//  Created by Ruslan Iskhakov on 09.11.2022.
//

import RxRelay

protocol FirstScreenViewModelProtocol {
    init(with appModel: AppModelProtocol)
    var showSecondEvent: (() -> ())? {get set}
    var refreshButtonEnabled: BehaviorRelay<Bool> {get}
    var networkStateText: BehaviorRelay<String> {get}
    var ipAddressText: BehaviorRelay<String> {get}
    var peerIPAddressPrefix: BehaviorRelay<String> {get}
    func configureView()
    func showSecondTap()
    func startServerTap()
    func startClientTap()
    func tryAudioTap()
    func refreshTap()
}
