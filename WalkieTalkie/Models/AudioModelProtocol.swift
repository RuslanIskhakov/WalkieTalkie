//
//  AudioModelProtocol.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 12.11.2022.
//

import RxRelay

enum WalkieTalkieState {
    case idle
    case transmitting
    case receiving
}

protocol AudioModelProtocol {
    var appModel: AppModelProtocol? {get set}
    var wkState: BehaviorRelay<WalkieTalkieState> {get set}
}
