//
//  WebSocketServerProtocol.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 15.11.2022.
//

import Foundation

protocol WebSocketServerProtocol {
    init(port: UInt16)
    func startServer()
}
