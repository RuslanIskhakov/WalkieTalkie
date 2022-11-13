//
//  AppModelProtocol.swift
//  BaseMVVMApp
//
//  Created by Ruslan Iskhakov on 09.11.2022.
//

import Foundation

protocol AppModelProtocol: AnyObject {
    var counterModel: CounterModelProtocol {get}
    var serverModel: SocketServerModelProtocol {get}
    var clientModel: SocketClientModelProtocol {get}
    var audioModel: AudioModelProtocol {get}
}
