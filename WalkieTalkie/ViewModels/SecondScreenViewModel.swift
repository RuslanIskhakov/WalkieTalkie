//
//  SecondScreenViewModel.swift
//  BaseMVVMApp
//
//  Created by Ruslan Iskhakov on 09.11.2022.
//

import RxRelay
import RxSwift

class SecondScreenViewModel: BaseViewModel, SecondScreenViewModelProtocol {

    private let appModel: AppModelProtocol

    required init(with appModel: AppModelProtocol) {
        self.appModel = appModel

        super.init()

        self.setupBindings()
    }

    let wkState = BehaviorRelay<WalkieTalkieState>(value: .idle)
    let connectivityState = BehaviorRelay<ConnectivityState>(value: .ok)
    let peerDistance = BehaviorRelay<String>(value: "")

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

        self.appModel.locationModel.peerDistance
            .observe(on: MainScheduler.instance)
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] distance in
                guard let self else { return }
                self.peerDistance.accept("Расстояние: \(distance == nil ? "?" : String(distance ?? 0)) м.")
            }).disposed(by: self.disposeBag)
    }
}
