//
//  AppSettingsModel.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 14.11.2022.
//

import Foundation

class AppSettingsModel: BaseModelInitialisable, AppSettingsModelProtocol {

    private let defaults = UserDefaults.standard

    private let peerIPAddressKey = "peeripaddress"
    private let portNumberKey = "portnumber"

    weak var appModel: AppModelProtocol?
    var peerIPAddress: String {
        set {
            self.defaults.set(newValue, forKey: self.peerIPAddressKey)
        }
        get {
            return self.defaults.string(forKey: self.peerIPAddressKey) ?? ""
        }
    }

    var portNumber: String {
        set {
            self.defaults.set(newValue, forKey: self.portNumberKey)
        }
        get {
            return self.defaults.string(forKey: self.portNumberKey) ?? "8080"
        }
    }
    
}
