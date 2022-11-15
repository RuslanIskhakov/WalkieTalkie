//
//  SocketCleintModelProtocol.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 11.11.2022.
//

import Foundation

protocol SocketClientModelProtocol {
    var appModel: AppModelProtocol? {get set}

    func startClient()
    func stopClient()
    func sendData(_ buffer: CircledSamplesBuffer<SampleFormat>)
}
