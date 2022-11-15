//
//  SocketClientModel.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 11.11.2022.
//

import Foundation

class SocketClientModel: BaseModelInitialisable, SocketClientModelProtocol {
    weak var appModel: AppModelProtocol?

    private var client: SwiftWebSocketClient?

    func startClient() {
        print("Starting SwiftWebSocketClient")
        let peerIPAddress = self.appModel?.appSettingsModel.peerIPAddress ?? ""
        let portNumber = self.appModel?.appSettingsModel.portNumber ?? "8080"
        self.client = SwiftWebSocketClient(ipAddress: peerIPAddress, port: portNumber)
        self.client?.subscribeToService() {[weak self] str in
            print("Completion: \(str)")
        }
    }

    func stopClient() {
        self.client?.closeSocket()
        self.client = nil
    }

    func sendData(_ buffer: CircledSamplesBuffer<SampleFormat>) {
        self.client?.sendData(buffer)
    }
}
