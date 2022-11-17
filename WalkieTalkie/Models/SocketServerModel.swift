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

    private var server: WebSocketServer?

    func startServer() {
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

        server.startServer()
        self.server = server
    }

    func stopServer() {
        print("SocketServerModel.stopServer()")

        self.disposeBag = DisposeBag()
        self.server?.stopServer()
    }
}
