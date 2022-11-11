//
//  CounterModelProtocol.swift
//  BaseMVVMApp
//
//  Created by Ruslan Iskhakov on 09.11.2022.
//

import Foundation

protocol CounterModelProtocol {
    var appModel: AppModelProtocol? {get set}
    var counter: Int {get}
    func increment()
}
