//
//  FirstScreenViewModelProtocol.swift
//  BaseMVVMApp
//
//  Created by Ruslan Iskhakov on 09.11.2022.
//

import Foundation

protocol FirstScreenViewModelProtocol {
    init(with appModel: AppModelProtocol)
    var showSecondEvent: (() -> ())? {get set}
    func showSecondTap()
}
