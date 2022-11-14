//
//  AppModel.swift
//  BaseMVVMApp
//
//  Created by Ruslan Iskhakov on 09.11.2022.
//

import Foundation

class AppModel: BaseModelInitialisable, AppModelProtocol {

    var counterModel: CounterModelProtocol
    var serverModel: SocketServerModelProtocol
    var clientModel: SocketClientModelProtocol
    var audioModel: AudioModelProtocol
    var connectivityUtils: ConnectivityUtilsProtocol

    init(
        counterModel: CounterModelProtocol,
        serverModel: SocketServerModelProtocol,
        clientModel: SocketClientModelProtocol,
        audioModel: AudioModelProtocol,
        connectivityUtils: ConnectivityUtilsProtocol
    ) {

        self.counterModel = counterModel
        self.serverModel = serverModel
        self.clientModel = clientModel
        self.audioModel = audioModel
        self.connectivityUtils = connectivityUtils

        super.init()

        self.counterModel.appModel = self
        self.serverModel.appModel = self
        self.clientModel.appModel = self
        self.audioModel.appModel = self
        self.connectivityUtils.appModel = self
    }
}
