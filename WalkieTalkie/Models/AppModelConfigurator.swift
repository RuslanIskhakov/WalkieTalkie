//
//  AppModelConfigurator.swift
//  BaseMVVMApp
//
//  Created by Ruslan Iskhakov on 09.11.2022.
//

import Foundation

class AppModelConfigurator {
    static func configure() -> AppModelProtocol {
        AppModel(
            serverModel: SocketServerModel(),
            clientModel: SocketClientModel(),
            audioModel: AudioModel(),
            connectivityUtils: ConnectivityUtils(),
            appSettingsModel: AppSettingsModel()
        )
    }
}
