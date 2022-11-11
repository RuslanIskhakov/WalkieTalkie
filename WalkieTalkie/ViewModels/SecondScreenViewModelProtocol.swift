//
//  SecondScreenViewModelProtocol.swift
//  BaseMVVMApp
//
//  Created by Ruslan Iskhakov on 09.11.2022.
//

import Foundation

protocol SecondScreenViewModelProtocol {
    init(with appModel: AppModelProtocol)
    var showCounterValueEvent: ((Int) -> ())? {get set}
    func incrementTap()
}
