//
//  BaseModelInitialisable.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 14.11.2022.
//

import RxSwift

class BaseModelInitialisable: NSObject {
    override init() {
        super.init()
        print("\(String(describing: type(of: self))) initialised")
    }

    var disposeBag = DisposeBag()
}
