//
//  SecondScreenViewModel.swift
//  BaseMVVMApp
//
//  Created by Ruslan Iskhakov on 09.11.2022.
//

import Foundation

class SecondScreenViewModel: SecondScreenViewModelProtocol {

    private let appModel: AppModelProtocol

    var showCounterValueEvent: ((Int) -> ())? {
        didSet {
            self.showCounterValueEvent?(self.counterValue)
        }
    }

    private var counterValue: Int {
        didSet {
            self.showCounterValueEvent?(self.counterValue)
        }
    }

    required init(with appModel: AppModelProtocol) {
        self.appModel = appModel
        self.counterValue = self.appModel.counterModel.counter
    }

    func incrementTap() {
        self.appModel.counterModel.increment()
        self.counterValue = self.appModel.counterModel.counter
    }

    deinit {
        print("dstest deinit SecondScreenViewModel")
    }
}
