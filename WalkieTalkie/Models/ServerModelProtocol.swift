//
//  ServerModelProtocol.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 11.11.2022.
//

import Foundation

protocol ServerModelProtocol {
    var appModel: AppModelProtocol? {get set}
    func startServer()
}
