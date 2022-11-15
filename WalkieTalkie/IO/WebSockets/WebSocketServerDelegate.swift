//
//  WebSocketServerDelegate.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 15.11.2022.
//

import Foundation

protocol WebSocketServerDelegate:AnyObject {
    func receivedSamples(_ samples: Array<SampleFormat>)
}
