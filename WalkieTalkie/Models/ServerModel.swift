//
//  ServerModel.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 11.11.2022.
//

import Foundation

class ServerModel: ServerModelProtocol {

    weak var appModel: AppModelProtocol?

    private var server: SwiftWebSocketServer?

    func startServer() {
        print("ServerModel.startServer()")

        self.server = SwiftWebSocketServer(port: 8080)
        self.server?.startServer()
    }
}
