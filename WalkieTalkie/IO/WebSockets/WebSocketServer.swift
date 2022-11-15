//
//  WebSocketServer.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 11.11.2022.
//  based on https://github.com/jayesh15111988/SwiftWebSocket/tree/master
//

import Foundation
import Network

class WebSocketServer: BaseIOInitialisable {
    var listener: NWListener
    var connectedClients: [NWConnection] = []
    var timer: Timer?
    let serverQueue = DispatchQueue(label: "ServerQueue")

    required init(port: UInt16) {

        let parameters = NWParameters(tls: nil)
        parameters.allowLocalEndpointReuse = true
        parameters.includePeerToPeer = true

        let wsOptions = NWProtocolWebSocket.Options()
        wsOptions.autoReplyPing = true

        parameters.defaultProtocolStack.applicationProtocols.insert(wsOptions, at: 0)

        do {
            if let port = NWEndpoint.Port(rawValue: port) {
                listener = try NWListener(using: parameters, on: port)
            } else {
                fatalError("Unable to start WebSocket server on port \(port)")
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func startServer() {

        listener.newConnectionHandler = { [weak self ]newConnection in
            guard let self else { return }

            print("New connection connecting")

            func receive() {
                newConnection.receiveMessage { (data, context, isComplete, error) in
                    if let data = data, let context = context {
                        if let decodedArray = NSKeyedUnarchiver.unarchiveObject(with: data) as? Array<SampleFormat> {
                            print("Received a new message from client of length:\(decodedArray.count)")
                        } else {
                            print("Cannot decode data")
                        }
                        //try! self.handleMessageFromClient(data: data, context: context, stringVal: "", connection: newConnection)
                        receive()
                    }
                }
            }
            receive()

            newConnection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    print("Client ready")
                    try! self.sendMessageToClient(data: JSONEncoder().encode(["t": "connect.connected"]), client: newConnection)
                case .failed(let error):
                    print("Client connection failed \(error.localizedDescription)")
                case .waiting(let error):
                    print("Waiting for long time \(error.localizedDescription)")
                default:
                    break
                }
            }

            newConnection.start(queue: self.serverQueue)
        }

        listener.stateUpdateHandler = { state in
            print(state)
            switch state {
            case .ready:
                print("Server Ready")
            case .failed(let error):
                print("Server failed with \(error.localizedDescription)")
            default:
                break
            }
        }

        listener.start(queue: serverQueue)
        //startTimer()
    }

    func stopServer() {
        timer?.invalidate()
        listener.cancel()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { timer in

            guard !self.connectedClients.isEmpty else {
                return
            }

            self.sendMessageToAllClients()

        })
        timer?.fire()
    }

    private func sendMessageToAllClients() {
        let data = getTradingQuoteData()
        for (index, client) in self.connectedClients.enumerated() {
            print("Sending message to client number \(index)")
            try! self.sendMessageToClient(data: data, client: client)
        }
    }

    private func sendMessageToClient(data: Data, client: NWConnection) throws {
        let metadata = NWProtocolWebSocket.Metadata(opcode: .binary)
        let context = NWConnection.ContentContext(identifier: "context", metadata: [metadata])

        client.send(content: data, contentContext: context, isComplete: true, completion: .contentProcessed({ error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                // no-op
            }
        }))
    }

    private func getTradingQuoteData() -> Data {
        let data = SocketQuoteResponse(t: "trading.quote", body: QuoteResponseBody(securityId: "100", currentPrice: String(Int.random(in: 1...1000))))
        return try! JSONEncoder().encode(data)
    }

    private func handleMessageFromClient(data: Data, context: NWConnection.ContentContext, stringVal: String, connection: NWConnection) throws {

        if let message = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            if message["subscribeTo"] != nil {

                print("Appending new connection to connectedClients")

                self.connectedClients.append(connection)

                self.sendAckToClient(connection: connection)

                let tradingQuoteData = self.getTradingQuoteData()
                try! self.sendMessageToClient(data: tradingQuoteData, client: connection)

            } else if message["unsubscribeFrom"] != nil {

                print("Removing old connection from connectedClients")

                if let id = message["unsubscribeFrom"] as? Int {
                    let connection = self.connectedClients.remove(at: id)
                    connection.cancel()
                    print("Cancelled old connection with id \(id)")
                } else {
                    print("Invalid Payload")
                }
            }
        } else {
            print("Invalid value from client")
        }
    }

    private func sendAckToClient(connection: NWConnection) {
        let model = ConnectionAck(t: "connect.ack", connectionId: self.connectedClients.count - 1)
        let data = try! JSONEncoder().encode(model)

        try! self.sendMessageToClient(data: data, client: connection)
    }
}

struct SocketQuoteResponse: Codable {
    let t: String
    let body: QuoteResponseBody
}

struct QuoteResponseBody: Codable {
    let securityId: String
    let currentPrice: String
}

struct ConnectionAck: Codable {
    let t: String
    let connectionId: Int
}
