//
//  AppModel.swift
//  BaseMVVMApp
//
//  Created by Ruslan Iskhakov on 09.11.2022.
//

import Foundation

class AppModel: AppModelProtocol {

    var counterModel: CounterModelProtocol
    var serverModel: SocketServerModelProtocol
    var clientModel: SocketClientModelProtocol

    init(
        counterModel: CounterModelProtocol,
        serverModel: SocketServerModelProtocol,
        clientModel: SocketClientModelProtocol
    ) {
        print("dstest init AppModel")

        self.counterModel = counterModel
        self.serverModel = serverModel
        self.clientModel = clientModel

        self.counterModel.appModel = self
        self.serverModel.appModel = self
        self.clientModel.appModel = self
    }
}
