//
//  AppModel.swift
//  BaseMVVMApp
//
//  Created by Ruslan Iskhakov on 09.11.2022.
//

import Foundation

class AppModel: AppModelProtocol {

    var counterModel: CounterModelProtocol

    init(
        counterModel: CounterModelProtocol
    ) {
        print("dstest init AppModel")

        self.counterModel = counterModel

        self.counterModel.appModel = self
    }
}
