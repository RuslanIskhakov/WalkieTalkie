//
//  SocketServerModel.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 11.11.2022.
//

import Foundation

class SocketServerModel: BaseModelInitialisable, SocketServerModelProtocol {

    weak var appModel: AppModelProtocol?

    private var server: WebSocketServer?

    func startServer() {
        print("SocketServerModel.startServer()")

        let portNumber = self.appModel?.appSettingsModel.portNumber ?? "8080"
        let port = UInt16(portNumber) ?? 8080
        self.server = WebSocketServer(port: port)
        self.server?.startServer()
    }

    func stopServer() {
        print("SocketServerModel.stopServer()")

        self.server?.stopServer()
    }
}
