//
//  SpcketServerModelProtocol.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 11.11.2022.
//

import Foundation

protocol SocketServerModelProtocol {
    var appModel: AppModelProtocol? {get set}
    func startServer()
}
