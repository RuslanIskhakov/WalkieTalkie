//
//  SwiftWebSocketClient.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 11.11.2022.
//  based on https://github.com/jayesh15111988/SwiftWebSocket/tree/master
//

import Foundation

final class SwiftWebSocketClient: NSObject {

    private let queue = DispatchQueue(label: "SwiftWebSocketClient", qos: .utility)

    private var webSocket: URLSessionWebSocketTask?

    var opened = false

    private var urlString = ""

    var connectionId = -1

    init(ipAddress: String, port: String) {
        self.urlString = "ws://\(ipAddress):\(port)"
        print("SwiftWebSocketClient init: \(self.urlString)")
    }

    func subscribeToService(with completion: @escaping (String?) -> Void) {
        if !opened {
            openWebSocket()
            print("SwiftWebSocketClient: socket is opened \(self.webSocket?.state)")
        }

        guard let webSocket = webSocket else {
            completion("webSocket is nil!!!")
            return
        }

        webSocket.receive(completionHandler: { [weak self] result in

            guard let self = self else { return }

            switch result {
            case .failure(let error):
                completion(error.localizedDescription)
            case .success(let webSocketTaskMessage):
                switch webSocketTaskMessage {
                case .string:
                    completion("")
                case .data(let data):
                    if let messageType = self.getMessageType(from: data) {
                        switch(messageType) {
                        case .connected:
                            completion("dstest Connected")
                            //self.subscribeToServer(completion: completion)
                        case .failed:
                            self.opened = false
                            completion("dstest Failed")
                        case .tradingQuote:
                            if let currentQuote = self.getCurrentQuoteResponseData(from: data) {
                                completion(currentQuote.body.currentPrice)
                            } else {
                                completion("excepted trading quote")
                            }
                        case .connectionAck:
                            let ack = try! JSONDecoder().decode(ConnectionAck.self, from: data)
                            self.connectionId = ack.connectionId
                            completion("dstest .connectionAck")
                        }
                    }

                    self.subscribeToService(with: completion)
                default:
                    fatalError("Failed. Received unknown data format. Expected String")
                }
            }
        })
    }

    func sendData(_ buffer: CircledSamplesBuffer<SampleFormat>) {
        //print("dstest sendData: \(buffer.available)")
        guard let webSocket = webSocket else {
            return
        }

        let encodedData = NSKeyedArchiver.archivedData(withRootObject: buffer.getAllSamples())

        webSocket.send(URLSessionWebSocketTask.Message.data(encodedData)) { error in
            if let error = error {
                print("Failed to send data with Error \(error.localizedDescription)")
            }
        }

    }

    private func getMessageType(from jsonData: Data) -> MessageType? {
        if let messageType = (try? JSONDecoder().decode(GenericSocketResponse.self, from: jsonData))?.t {
            return MessageType(rawValue: messageType)
        }
        return nil
    }

    private func getCurrentQuoteResponseData(from jsonData: Data) -> SocketQuoteResponse? {
        do {
            return try JSONDecoder().decode(SocketQuoteResponse.self, from: jsonData)
        } catch {
            return nil
        }
    }

    private func subscriptionPayload(for productID: String) -> String? {
        let payload = ["subscribeTo": "trading.product.\(productID)"]
        if let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: []) {
            return String(data: jsonData, encoding: .utf8)
        }
        return nil
    }

    private func subscribeToServer(completion: @escaping (String?) -> Void) {

        guard let webSocket = webSocket else {
            return
        }

        if let subscriptionPayload = self.subscriptionPayload(for: "100") {
            webSocket.send(URLSessionWebSocketTask.Message.string(subscriptionPayload)) { error in
                if let error = error {
                    print("Failed with Error \(error.localizedDescription)")
                }
            }
        } else {
            completion(nil)
        }
    }

    private func openWebSocket() {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            let webSocket = session.webSocketTask(with: request)
            self.webSocket = webSocket
            self.opened = true
            self.webSocket?.resume()
        } else {
            webSocket = nil
        }
    }

    func closeSocket() {
        webSocket?.cancel(with: .goingAway, reason: nil)
        opened = false
        webSocket = nil
        print("SwiftWebSocketClient: socket is closed")
    }
}

extension SwiftWebSocketClient: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        opened = true
    }


    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        self.webSocket = nil
        self.opened = false
    }
}


struct GenericSocketResponse: Decodable {
    let t: String
}

enum MessageType: String {
    case connected = "connect.connected"
    case failed =  "connect.failed"
    case tradingQuote = "trading.quote"
    case connectionAck = "connect.ack"
}
