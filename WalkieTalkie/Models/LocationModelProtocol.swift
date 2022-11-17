//
//  LocationModelProtocol.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 17.11.2022.
//

import RxSwift
import RxRelay

protocol LocationModelProtocol: AnyObject {
    var appModel: AppModelProtocol? {get set}
    var lastLocation: BehaviorRelay<LocationBody?> {get}

    func startTracking()
    func stopTracking()
}
