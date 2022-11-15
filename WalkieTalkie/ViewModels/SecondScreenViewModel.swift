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

        super.init()

        self.setupBindings()
    }

    let wkState = BehaviorRelay<WalkieTalkieState>(value: .idle)
    let connectivityState = BehaviorRelay<ConnectivityState>(value: .ok)

    func viewDidAppear() {
        self.appModel.serverModel.startServer()
    }

    func viewWillDisappear() {
        self.appModel.serverModel.stopServer()
    }

    func pttTouchDown() {
        self.connectivityState.accept(.noConnection)
        self.appModel.audioModel.wkState.accept(.transmitting)
    }

    func pttTouchUp() {
        self.connectivityState.accept(.ok)
        self.appModel.audioModel.wkState.accept(.idle)
    }

    private func setupBindings() {
        self.wkState
            .asObservable()
            .bind(to: self.appModel.audioModel.wkState)
            .disposed(by: self.disposeBag)
    }
}
