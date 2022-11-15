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

    var available: Int {
        self.writeIndex >= self.readIndex ?
        self.writeIndex - self.readIndex :
        self.capacity - self.readIndex + self.writeIndex
    }

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

    func getSample() -> T? {
        guard self.readIndex != self.writeIndex else { return nil }

        let sample = self.samples[self.readIndex]
        self.readIndex += 1;
        if self.readIndex >= self.capacity {self.readIndex = 0}
        return sample
    }

    func getAllSamples() -> Array<T> {
        var result = Array<T>()

        if (self.writeIndex >= self.readIndex) {
            result.append(contentsOf: self.samples[self.readIndex..<self.writeIndex])
        } else {
            result.append(contentsOf: self.samples[self.readIndex..<self.capacity])
            result.append(contentsOf: self.samples[0..<self.writeIndex])
        }

        self.readIndex = self.writeIndex

        return result
    }
}
