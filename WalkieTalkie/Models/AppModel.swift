//
//  AppModel.swift
//  BaseMVVMApp
//
//  Created by Ruslan Iskhakov on 09.11.2022.
//

import RxSwift

class AppModel: BaseModelInitialisable, AppModelProtocol {

    var serverModel: SocketServerModelProtocol
    var clientModel: SocketClientModelProtocol
    var audioModel: AudioModelProtocol
    var connectivityUtils: ConnectivityUtilsProtocol
    var appSettingsModel: AppSettingsModelProtocol
    var locationModel: LocationModelProtocol

    init(
        serverModel: SocketServerModelProtocol,
        clientModel: SocketClientModelProtocol,
        audioModel: AudioModelProtocol,
        connectivityUtils: ConnectivityUtilsProtocol,
        appSettingsModel: AppSettingsModelProtocol,
        locationModel: LocationModelProtocol
    ) {

        self.serverModel = serverModel
        self.clientModel = clientModel
        self.audioModel = audioModel
        self.connectivityUtils = connectivityUtils
        self.appSettingsModel = appSettingsModel
        self.locationModel = locationModel

        super.init()

        self.serverModel.appModel = self
        self.clientModel.appModel = self
        self.audioModel.appModel = self
        self.connectivityUtils.appModel = self
        self.appSettingsModel.appModel = self
        self.locationModel.appModel = self
    }
}
