//
//  SecondScreenViewModel.swift
//  BaseMVVMApp
//
//  Created by Ruslan Iskhakov on 09.11.2022.
//

import RxRelay

class SecondScreenViewModel: SecondScreenViewModelProtocol {

    private let appModel: AppModelProtocol

    let showCounterValueEvent = BehaviorRelay<Int>(value: 0)

    required init(with appModel: AppModelProtocol) {
        self.appModel = appModel
        self.showCounterValueEvent.accept(self.appModel.counterModel.counter)
    }

    func incrementTap() {
        self.appModel.counterModel.increment()
        self.showCounterValueEvent.accept(self.appModel.counterModel.counter)
    }

    deinit {
        print("dstest deinit SecondScreenViewModel")
    }
}
