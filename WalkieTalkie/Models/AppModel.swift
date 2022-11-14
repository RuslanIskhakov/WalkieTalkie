//
//  AppModel.swift
//  BaseMVVMApp
//
//  Created by Ruslan Iskhakov on 09.11.2022.
//

import Foundation

class AppModel: BaseModelInitialisable, AppModelProtocol {

    var serverModel: SocketServerModelProtocol
    var clientModel: SocketClientModelProtocol
    var audioModel: AudioModelProtocol
    var connectivityUtils: ConnectivityUtilsProtocol
    var appSettingsModel: AppSettingsModelProtocol

    init(
        serverModel: SocketServerModelProtocol,
        clientModel: SocketClientModelProtocol,
        audioModel: AudioModelProtocol,
        connectivityUtils: ConnectivityUtilsProtocol,
        appSettingsModel: AppSettingsModelProtocol
    ) {

        self.serverModel = serverModel
        self.clientModel = clientModel
        self.audioModel = audioModel
        self.connectivityUtils = connectivityUtils
        self.appSettingsModel = appSettingsModel

        super.init()

        self.serverModel.appModel = self
        self.clientModel.appModel = self
        self.audioModel.appModel = self
        self.connectivityUtils.appModel = self
        self.appSettingsModel.appModel = self
    }
}
