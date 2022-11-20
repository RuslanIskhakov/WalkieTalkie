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
    let errorDialogMessage = PublishSubject<String>()

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

        self.appModel.audioModel.wkState.accept(.transmitting)
    }

    func pttTouchUp() {
        if self.appModel.audioModel.wkState.value == .transmitting {
            self.appModel.audioModel.wkState.accept(.idle)
        }
    }

    private func setupBindings() {
        self.appModel.audioModel.wkState
            .bind(to: self.wkState)
            .disposed(by: self.disposeBag)

        self.appModel.locationModel.peerDistance
            .observe(on: SerialDispatchQueueScheduler(qos: .utility))
            .subscribe(on: SerialDispatchQueueScheduler(qos: .utility))
            .subscribe(onNext: {[weak self] distance in
                guard let self else { return }
                self.peerDistance.accept("Расстояние: \(distance == nil ? "?" : String(distance ?? 0)) м.")
            }).disposed(by: self.disposeBag)

        self.appModel.serverModel.serverErrorEvents
            .observe(on: SerialDispatchQueueScheduler(qos: .utility))
            .subscribe(on: SerialDispatchQueueScheduler(qos: .utility))
            .subscribe(onNext: {[weak self] distance in
                guard let self else { return }
                self.errorDialogMessage.onNext("Не удалось поднять сокет-сервер. Пожалуйста, повторите через несколько минут или измените номер порта.")
            }).disposed(by: self.disposeBag)

        self.appModel.clientModel.clientErrorEvents
            .observe(on: SerialDispatchQueueScheduler(qos: .utility))
            .subscribe(on: SerialDispatchQueueScheduler(qos: .utility))
            .subscribe(onNext: {[weak self] distance in
                guard let self else { return }
                self.appModel.serverModel.stopServer()
                self.appModel.clientModel.stopClient()
                self.appModel.locationModel.stopTracking()
                self.errorDialogMessage.onNext("Не удалось подключиться к сокет-серверу. Пожалуйста, проверьте номер порта.")
            }).disposed(by: self.disposeBag)

        self.appModel.clientModel.sendMessageErrorEvents
            .observe(on: SerialDispatchQueueScheduler(qos: .utility))
            .subscribe(on: SerialDispatchQueueScheduler(qos: .utility))
            .subscribe(onNext: {[weak self] in
                guard let self else { return }
                self.connectivityState.accept(.noConnection)
            }).disposed(by: self.disposeBag)

        self.appModel.clientModel.sendMessageErrorEvents
            .observe(on: SerialDispatchQueueScheduler(qos: .utility))
            .subscribe(on: SerialDispatchQueueScheduler(qos: .utility))
            .debounce(.milliseconds(500), scheduler: SerialDispatchQueueScheduler(qos: .utility))
            .subscribe(onNext: {[weak self] in
                guard let self else { return }
                self.connectivityState.accept(.ok)
            }).disposed(by: self.disposeBag)
    }
}
