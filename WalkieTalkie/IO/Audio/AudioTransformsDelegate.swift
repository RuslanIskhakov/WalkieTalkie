//
//  AudioTransformsDelegate.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 15.11.2022.
//

import Foundation

protocol AudioTransformsDelegate: AnyObject {
    func getStatus() -> WalkieTalkieState
    func sendSamples(_ buffer: CircledSamplesBuffer<SampleFormat>)
}
