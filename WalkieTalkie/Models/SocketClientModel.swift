//
//  SocketClientModel.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 11.11.2022.
//

import RxSwift

class SocketClientModel: BaseModelInitialisable, SocketClientModelProtocol {
    weak var appModel: AppModelProtocol?

    private var client: WebSocketClient?
    private var locationSent = false

    func startClient() {
        print("Starting WebSocketClient")
        let peerIPAddress = self.appModel?.appSettingsModel.peerIPAddress ?? ""
        let portNumber = self.appModel?.appSettingsModel.portNumber ?? "8080"
        self.client = WebSocketClient(ipAddress: peerIPAddress, port: portNumber)

        self.client?.connectionEvents
            .subscribe(on: SerialDispatchQueueScheduler(qos: .utility))
            .observe(on: SerialDispatchQueueScheduler(qos: .utility))
            .subscribe(onNext: { [weak self] event in
                guard let self else { return }
                switch event {
                case .connected:
                    guard let location = self.appModel?.locationModel.lastLocation.value else { return }
                    self.client?.sendLocation(location)
                case .locationAck:
                    self.locationSent = true
                }

            })
            .disposed(by: self.disposeBag)

        self.client?.serverLocation
            .subscribe(on: SerialDispatchQueueScheduler(qos: .utility))
            .observe(on: SerialDispatchQueueScheduler(qos: .utility))
            .subscribe(onNext: { [weak self] location in
                guard let self else { return }
                self.appModel?.serverModel.clientLocation.accept(location)
            })
            .disposed(by: self.disposeBag)

        self.client?.subscribeToService() {str in
            print("Completion: \(str)")
        }

    }

    func stopClient() {
        self.locationSent = false
        self.disposeBag = DisposeBag()
        self.client?.closeSocket()
        self.client = nil
    }

    func sendData(_ buffer: CircledSamplesBuffer<SampleFormat>) {
        guard self.locationSent == true else { return }
        self.client?.sendData(buffer)
    }
}
