//
//  SocketServerModel.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 11.11.2022.
//

import RxSwift
import RxRelay

class SocketServerModel: BaseModelInitialisable, SocketServerModelProtocol {

    weak var appModel: AppModelProtocol?

    let clientLocation = PublishRelay<LocationBody>()
    let serverErrorEvents = PublishSubject<Void>()

    private var server: WebSocketServer?
    private let queue = DispatchQueue(label: "SocketServerModel", qos: .utility)

    func startServer() {
        self.queue.async {[unowned self] in
            print("SocketServerModel.startServer()")

            let portNumber = self.appModel?.appSettingsModel.portNumber ?? "8080"
            let port = UInt16(portNumber) ?? 8080
            let server = WebSocketServer(
                port: port,
                delegate: self.appModel?.audioModel
            )

            server.clientLocation
                .bind(to: self.clientLocation)
                .disposed(by: self.disposeBag)

            self.appModel?.locationModel.lastLocation
                .bind(to: server.lastLocation)
                .disposed(by: self.disposeBag)

            server.stateEvents
                .subscribe(on: SerialDispatchQueueScheduler(qos: .utility))
                .observe(on: SerialDispatchQueueScheduler(qos: .utility))
                .subscribe(onNext: { [weak self] event in
                    guard let self else { return }
                    switch event {
                    case .initial:
                        print("SocketServer state is initial")
                    case .errorMessage(let msg):
                        print("SocketServer error: \(msg)")
                        self.serverErrorEvents.onNext(())
                    case .error(let error):
                        print("SocketServer error: \(error.localizedDescription)")
                    case .opened(let msg):
                        print("SocketServer opened: \(msg)")
                    case .event(let msg):
                        print("SocketServer event: \(msg)")
                    }
                })
                .disposed(by: self.disposeBag)

            server.startServer()
            self.server = server
        }
    }

    func stopServer() {
        self.queue.async {[unowned self] in
            print("SocketServerModel.stopServer()")
            
            self.disposeBag = DisposeBag()
            self.server?.stopServer()
        }
    }
}
