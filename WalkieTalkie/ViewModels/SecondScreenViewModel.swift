//
//  SecondScreenViewModel.swift
//  BaseMVVMApp
//
//  Created by Ruslan Iskhakov on 09.11.2022.
//

import RxRelay

class SecondScreenViewModel: BaseViewModel, SecondScreenViewModelProtocol {

    private let appModel: AppModelProtocol

    required init(with appModel: AppModelProtocol) {
        self.appModel = appModel
    }

    let wkState = BehaviorRelay<WalkieTalkieState>(value: .idle)
    let connectivityState = BehaviorRelay<ConnectivityState>(value: .ok)

    func viewDidAppear() {
        //self.appModel.serverModel.startServer()
    }

    func viewWillDisappear() {

    }

    func pttTouchDown() {
        self.connectivityState.accept(.noConnection)
        self.wkState.accept(.transmitting)
    }

    func pttTouchUp() {
        self.connectivityState.accept(.ok)
        self.wkState.accept(.idle)
    }
}
