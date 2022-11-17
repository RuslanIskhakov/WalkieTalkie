//
//  LocationModelProtocol.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 17.11.2022.
//

import Foundation

protocol LocationModelProtocol: AnyObject {
    var appModel: AppModelProtocol? {get set}

    func startTracking()
    func stopTracking()
}
