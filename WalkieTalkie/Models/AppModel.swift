//
//  AppModel.swift
//  BaseMVVMApp
//
//  Created by Ruslan Iskhakov on 09.11.2022.
//

import Foundation

class AppModel: AppModelProtocol {

    var counterModel: CounterModelProtocol
    var serverModel: ServerModelProtocol

    init(
        counterModel: CounterModelProtocol,
        serverModel: ServerModelProtocol
    ) {
        print("dstest init AppModel")

        self.counterModel = counterModel
        self.serverModel = serverModel

        self.counterModel.appModel = self
        self.serverModel.appModel = self
    }
}
