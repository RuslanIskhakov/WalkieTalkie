//
//  SocketCleintModelProtocol.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 11.11.2022.
//

import RxSwift

protocol SocketClientModelProtocol {
    var appModel: AppModelProtocol? {get set}
    var clientErrorEvents: PublishSubject<Void> {get}
    var sendMessageErrorEvents: PublishSubject<Void> {get}
    func startClient()
    func stopClient()
    func sendData(_ buffer: CircledSamplesBuffer<SampleFormat>)
}
