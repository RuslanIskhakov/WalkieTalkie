//
//  BaseViewModel.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 14.11.2022.
//

import Foundation

class BaseViewModel {
    init() {
        print("\(String(describing: type(of: self))) created")
    }

    deinit {
        print("deinit for \(String(describing: type(of: self)))")
    }
}
