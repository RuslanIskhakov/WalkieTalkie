//
//  SpcketServerModelProtocol.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 11.11.2022.
//

import RxRelay
import RxSwift

protocol SocketServerModelProtocol {
    var appModel: AppModelProtocol? {get set}
    var clientLocation: PublishRelay<LocationBody> {get}
    var serverErrorEvents: PublishSubject<Void> {get}
    func startServer()
    func stopServer()
}
