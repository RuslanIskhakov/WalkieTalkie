//
//  ConnectivityUtilsProtocol.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 14.11.2022.
//

import Foundation

protocol ConnectivityUtilsProtocol {
    var appModel: AppModelProtocol? {get set}
    func getIP() -> String?
    func getPeerIpAddressPrefix(for ipAddress: String) -> String
}
