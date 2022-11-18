//
//  WebSocketClient.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 11.11.2022.
//  based on https://github.com/jayesh15111988/SwiftWebSocket/tree/master
//

import RxSwift
import RxRelay

final class WebSocketClient: NSObject {

    private let queue = DispatchQueue(label: "WebSocketClient", qos: .utility)

    private var webSocket: URLSessionWebSocketTask?

    private var opened = false

    private var urlString = ""

    let connectionEvents = PublishRelay<MessageType>()
    let serverLocation = PublishRelay<LocationBody>()

    init(ipAddress: String, port: String) {
        self.urlString = "ws://\(ipAddress):\(port)"
        print("WebSocketClient init: \(self.urlString)")
    }

    func subscribeToService(with completion: @escaping (String?) -> Void) {

        self.queue.async {[unowned self] in
            if !self.opened {
                self.openWebSocket()
                print("WebSocketClient: socket is opened \(self.webSocket?.state)")
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
                        if let messageType = self.getMessageType(from: data) {
                            switch(messageType) {
                            case .connected:
                                completion("dstest Connected")

                                if let location = try? JSONDecoder().decode(ConnectionAck.self, from: data).lastLocation {
                                    self.serverLocation.accept(location)
                                }

                                self.connectionEvents.accept(.connected)
                            case .locationAck:
                                completion("dstest location ack")
                                self.connectionEvents.accept(.locationAck)
                            }
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

    private func getMessageType(from jsonData: Data) -> MessageType? {
        if let messageType = (try? JSONDecoder().decode(ConnectionAck.self, from: jsonData))?.t {
            return MessageType(rawValue: messageType)
        }
        return nil
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
            print("WebSocketClient: socket is closed")
        }
    }
}

extension WebSocketClient: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        opened = true
    }


    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        self.webSocket = nil
        self.opened = false
    }
}
