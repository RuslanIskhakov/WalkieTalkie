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
    private let queue = DispatchQueue(label: "SocketClientModel", qos: .utility)

    let clientErrorEvents = PublishSubject<Void>()
    let sendMessageErrorEvents = PublishSubject<Void>()

    func startClient() {
        self.queue.async {[unowned self] in
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

            self.client?.stateEvents
                .subscribe(on: SerialDispatchQueueScheduler(qos: .utility))
                .observe(on: SerialDispatchQueueScheduler(qos: .utility))
                .subscribe(onNext: { [weak self] event in
                    guard let self else { return }
                    switch event {
                    case .initial:
                        print("SocketClient state is initial")
                    case .errorMessage(let msg):
                        print("SocketClient error: \(msg)")
                        self.clientErrorEvents.onNext(())
                    case .error(let error):
                        print("SocketClient error: \(error.localizedDescription)")
                    case .opened(let msg):
                        print("SocketClient opened: \(msg)")
                    case .event(let msg):
                        print("SocketClient event: \(msg)")
                    case .sendDataError:
                        print("SocketClient event: postChatMessageError")
                        self.sendMessageErrorEvents.onNext(())
                    }
                })
                .disposed(by: self.disposeBag)

            print("Subscribing to service")
            self.client?.subscribeToService()
        }
    }

    func stopClient() {
        self.queue.async {[unowned self] in
            self.locationSent = false
            self.disposeBag = DisposeBag()
            self.client?.closeSocket()
            self.client = nil
        }
    }

    func sendData(_ buffer: CircledSamplesBuffer<SampleFormat>) {
        guard self.locationSent == true else { return }
        self.client?.sendData(buffer)
    }
}
