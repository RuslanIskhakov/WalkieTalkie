//
//  AppSettingsModelProtocol.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 14.11.2022.
//

import Foundation

protocol AppSettingsModelProtocol {
    var appModel: AppModelProtocol? {get set}
    var peerIPAddress: String {get set}
}
