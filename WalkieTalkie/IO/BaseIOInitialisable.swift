//
//  BaseIOInitialisable.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 14.11.2022.
//

import Foundation

class BaseIOInitialisable {
    init() {
        print("\(String(describing: type(of: self))) initialised")
    }
}
