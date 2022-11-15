//
//  CircledSamplesBuffer.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 15.11.2022.
//

import Foundation

class CircledSamplesBuffer<T: Numeric> {

    let capacity: Int

    private var samples: Array<T>
    private var writeIndex = 0
    private var readIndex = 0

    init(capacity: Int) {
        self.capacity = capacity
        self.samples = Array(repeating: T.zero, count: capacity)
    }

    func putSample(_ sample: T) {
        self.samples[writeIndex] = sample
        self.writeIndex += 1
        if self.writeIndex >= self.capacity { self.writeIndex = 0 }
        //print("dstest writeIndex: \(writeIndex) \(sample)")
    }

    func getSample() -> T {
        let sample = self.samples[self.readIndex]
        self.readIndex += 1;
        if self.readIndex >= self.capacity {self.readIndex = 0}
        return sample
    }
}
