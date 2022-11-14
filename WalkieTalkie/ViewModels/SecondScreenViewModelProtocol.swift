//
//  SecondScreenViewModelProtocol.swift
//  BaseMVVMApp
//
//  Created by Ruslan Iskhakov on 09.11.2022.
//

import RxRelay

enum WalkieTalkieState {
    case idle
    case transmitting
    case receiving
}

enum ConnectivityState {
    case ok
    case noConnection
}

protocol SecondScreenViewModelProtocol {
    init(with appModel: AppModelProtocol)

    var wkState: BehaviorRelay<WalkieTalkieState> {get}
    var connectivityState: BehaviorRelay<ConnectivityState> {get}

    func pttTouchDown()
    func pttTouchUp()
}
