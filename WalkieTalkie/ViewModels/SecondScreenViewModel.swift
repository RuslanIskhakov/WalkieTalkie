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
        self.appModel.locationModel.startTracking()
    }

    func viewWillDisappear() {
        self.appModel.serverModel.stopServer()
        self.appModel.locationModel.stopTracking()
    }

    func pttTouchDown() {
        guard self.appModel.audioModel.wkState.value == .idle else { return }

        self.connectivityState.accept(.noConnection)
        self.appModel.audioModel.wkState.accept(.transmitting)
    }

    func pttTouchUp() {
        self.connectivityState.accept(.ok)

        if self.appModel.audioModel.wkState.value == .transmitting {
            self.appModel.audioModel.wkState.accept(.idle)
        }
    }

    private func setupBindings() {
        self.appModel.audioModel.wkState
            .bind(to: self.wkState)
            .disposed(by: self.disposeBag)
    }
}
