//
//  BaseIOInitialisable.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 14.11.2022.
//

import Foundation

class BaseIOInitialisable: NSObject {
    override init() {
        print("\(String(describing: type(of: self))) initialised")
    }
}
