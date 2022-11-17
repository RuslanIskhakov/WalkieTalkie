//
//  SwiftWebSocketClient.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 11.11.2022.
//  based on https://github.com/jayesh15111988/SwiftWebSocket/tree/master
//

import RxSwift
import RxRelay

final class SwiftWebSocketClient: NSObject {

    private let queue = DispatchQueue(label: "SwiftWebSocketClient", qos: .utility)

    private var webSocket: URLSessionWebSocketTask?

    private var opened = false

    private var urlString = ""

    private var connectionId = -1

    let connectionEvents = PublishRelay<(MessageType, LocationBody?)>()

    init(ipAddress: String, port: String) {
        self.urlString = "ws://\(ipAddress):\(port)"
        print("SwiftWebSocketClient init: \(self.urlString)")
    }

    func subscribeToService(with completion: @escaping (String?) -> Void) {

        self.queue.async {[unowned self] in
            if !self.opened {
                self.openWebSocket()
                print("SwiftWebSocketClient: socket is opened \(self.webSocket?.state)")
            }

            guard let webSocket = self.webSocket else {
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
                        if
                            let message = self.getConnectionAck(from: data),
                            let messageType = MessageType(rawValue: message.t) {

                                switch messageType {
                                case .connected:
                                    completion("dstest Connected")
                                case .failed:
                                    self.opened = false
                                    completion("dstest Failed")
                                case .connectionAck:
                                    let ack = try! JSONDecoder().decode(ConnectionAck.self, from: data)
                                    self.connectionId = ack.connectionId
                                case .locationAck:
                                    completion("dstest location ack")
                                }
                                self.connectionEvents.accept((messageType, message.location))
                        }

                        self.subscribeToService(with: completion)
                    default:
                        fatalError("Failed. Received unknown data format. Expected String")
                    }
                }
            })
        }
    }

    func sendData(_ buffer: CircledSamplesBuffer<SampleFormat>) {
        //print("dstest sendData: \(buffer.available)")

        self.queue.async {[unowned self] in
            guard let webSocket = self.webSocket else {
                return
            }

            let encodedData = NSKeyedArchiver.archivedData(withRootObject: buffer.getAllSamples())

            webSocket.send(URLSessionWebSocketTask.Message.data(encodedData)) { error in
                if let error = error {
                    print("Failed to send data with Error \(error.localizedDescription)")
                }
            }
        }

    }

    func sendLocation(_ location: LocationBody) {
        self.queue.async {[unowned self] in
            guard let webSocket = self.webSocket else {
                return
            }
            print("dstest sending location: \(location)")
            if let data = try? JSONEncoder().encode(location) {
                webSocket.send(URLSessionWebSocketTask.Message.data(data)) {error in
                    if let error = error {
                        print("dstest sendLocation error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    private func getConnectionAck(from jsonData: Data) -> ConnectionAck? {
        return try? JSONDecoder().decode(ConnectionAck.self, from: jsonData)
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
        self.queue.sync {
            self.webSocket?.cancel(with: .goingAway, reason: nil)
            self.opened = false
            self.webSocket = nil
            print("SwiftWebSocketClient: socket is closed")
        }
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
    case connectionAck = "connect.ack"
    case locationAck = "location.ack"
}
