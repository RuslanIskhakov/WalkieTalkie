//
//  SpcketServerModelProtocol.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 11.11.2022.
//

import RxRelay

protocol SocketServerModelProtocol {
    var appModel: AppModelProtocol? {get set}
    var clientLocation: PublishRelay<LocationBody> {get}
    func startServer()
    func stopServer()
}
