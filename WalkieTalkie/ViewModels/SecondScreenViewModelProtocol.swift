//
//  SecondScreenViewModelProtocol.swift
//  BaseMVVMApp
//
//  Created by Ruslan Iskhakov on 09.11.2022.
//

import RxRelay

enum ConnectivityState {
    case ok
    case noConnection
}

protocol SecondScreenViewModelProtocol {
    init(with appModel: AppModelProtocol)

    var wkState: BehaviorRelay<WalkieTalkieState> {get}
    var connectivityState: BehaviorRelay<ConnectivityState> {get}
    var peerDistance: BehaviorRelay<String> {get}

    func viewDidAppear()
    func viewWillDisappear()

    func pttTouchDown()
    func pttTouchUp()
}
