//
//  CounterModel.swift
//  BaseMVVMApp
//
//  Created by Ruslan Iskhakov on 09.11.2022.
//

import Foundation

class CounterModel: CounterModelProtocol {

    weak var appModel: AppModelProtocol?

    var counter: Int = 0
    func increment() {
        self.counter += 1
    }
}
