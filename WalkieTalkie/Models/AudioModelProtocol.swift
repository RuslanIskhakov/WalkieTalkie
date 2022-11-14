//
//  AudioModelProtocol.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 12.11.2022.
//

import Foundation

protocol AudioModelProtocol {
    var appModel: AppModelProtocol? {get set}
    func tryIt()
}
