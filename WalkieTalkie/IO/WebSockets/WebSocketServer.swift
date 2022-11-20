//
//  WebSocketServer.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 11.11.2022.
//  based on https://github.com/jayesh15111988/SwiftWebSocket/tree/master
//

import Foundation
import Network
import RxSwift
import RxRelay

enum WebSocketServerStateEvents {
    case initial
    case errorMessage(String)
    case error(Error)
    case opened(String)
    case event(String)
}

class WebSocketServer: BaseIOInitialisable {
    private var listener: NWListener?
    private var connectedClients: [NWConnection] = []
    private let serverQueue = DispatchQueue(label: "ServerQueue")

    private weak var delegate: WebSocketServerDelegate?

    let clientLocation = PublishSubject<LocationBody>()
    let lastLocation = BehaviorRelay<LocationBody?>(value: nil)

    let stateEvents = BehaviorRelay<WebSocketServerStateEvents>(value: .initial)

    required init(port: UInt16, delegate: WebSocketServerDelegate? = nil) {

        self.delegate = delegate

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
                self.stateEvents.accept(.errorMessage("Unable to start WebSocket server on port \(port)"))
            }
        } catch {
            self.stateEvents.accept(.errorMessage(error.localizedDescription))
        }
    }

    func startServer() {

        listener?.newConnectionHandler = { [weak self ]newConnection in
            guard let self else { return }

            self.stateEvents.accept(.event("New connection"))

            func receive() {
                newConnection.receiveMessage { (data, context, isComplete, error) in
                    if let data = data, let context = context {
                        let someMessage = try? self.handleMessageFromClient(data: data, context: context, stringVal: "", connection: newConnection)
                        if someMessage != true {
                            if let decodedArray = NSKeyedUnarchiver.unarchiveObject(with: data) as? Array<SampleFormat> {
                                self.stateEvents.accept(.event("Received a new message from client of length:\(decodedArray.count)"))
                                self.delegate?.receivedSamples(decodedArray)
                            } else {
                                self.stateEvents.accept(.event("Cannot decode data"))
                            }
                        }
                        self.serverQueue.asyncAfter(deadline: .now() + .microseconds(1000)) {
                            receive()
                        }
                    }
                }
            }
            receive()

            newConnection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    self.stateEvents.accept(.event("Client ready"))
                    self.sendConnectionAckToClient(connection: newConnection)
                case .failed(let error):
                    self.stateEvents.accept(.error(error))
                case .waiting(let error):
                    self.stateEvents.accept(.error(error))
                default:
                    break
                }
            }

            newConnection.start(queue: self.serverQueue)
        }

        listener?.stateUpdateHandler = { state in
            print(state)
            switch state {
            case .ready:
                self.stateEvents.accept(.opened("Server Ready"))
            case .failed(let error):
                self.stateEvents.accept(.error(error))
            default:
                break
            }
        }

        listener?.start(queue: serverQueue)
    }

    func stopServer() {
        listener?.cancel()
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

    private func handleMessageFromClient(data: Data, context: NWConnection.ContentContext, stringVal: String, connection: NWConnection) throws -> Bool {

        if let location = try? JSONDecoder().decode(LocationBody.self, from: data) {
            self.stateEvents.accept(.event("dstest received location: \(location)"))
            self.clientLocation.onNext(location)
            self.sendLocationAckToClient(connection: connection)
            return true
        }

        self.stateEvents.accept(.event("Invalid value from client"))
        return false
    }

    private func sendConnectionAckToClient(connection: NWConnection) {

        let model = ConnectionAck(
            t: MessageType.connected.rawValue,
            lastLocation: self.lastLocation.value
        )
        let data = try! JSONEncoder().encode(model)

        try! self.sendMessageToClient(data: data, client: connection)
    }

    private func sendLocationAckToClient(connection: NWConnection) {

        let model = ConnectionAck(
            t: MessageType.locationAck.rawValue,
            lastLocation: self.lastLocation.value
        )
        let data = try! JSONEncoder().encode(model)

        try! self.sendMessageToClient(data: data, client: connection)
    }
}

struct LocationBody: Codable {
    let latitude: Double
    let longitude: Double
}

struct ConnectionAck: Codable {
    let t: String
    let lastLocation: LocationBody?
}

enum MessageType: String {
    case connected = "connect.connected"
    case locationAck = "location.ack"
}
