//
//  SocketClientModel.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 11.11.2022.
//

import Foundation

class SocketClientModel: SocketClientModelProtocol {
    weak var appModel: AppModelProtocol?

    private var client: SwiftWebSocketClient?

    func startClient() {
        print("Startting SwiftWebSocketClient")
        self.client = SwiftWebSocketClient()
        self.client?.subscribeToService() {[weak self] str in
            print("Completion: \(str)")
        }
    }
}
