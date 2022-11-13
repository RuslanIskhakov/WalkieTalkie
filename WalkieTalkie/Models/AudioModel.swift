//
//  AudioModel.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 12.11.2022.
//

import Foundation

class AudioModel: AudioModelProtocol {

    enum AudioState {
        case idle
        case recording
        case playing
    }


    weak var appModel: AppModelProtocol?

    private let queue = DispatchQueue(label: "AudioModel", qos: .utility)

    private var dataArray = [Float]()

    private let audioManager: Novocaine = Novocaine.audioManager()

    private var state: AudioState = .idle

    init() {
        self.audioManager.inputBlock = {[unowned self] data, numFrames, numChannels in
            guard self.state == .recording else {return}

            let array = Array(UnsafeBufferPointer(start: data, count: Int(numFrames * numChannels)))
            self.dataArray.append(contentsOf: array)
            print("dstest input frames number: \(numFrames) \(numChannels) \(array.count) (\(self.dataArray.count))")
        }

        self.audioManager.outputBlock = {[unowned self] data, numFrames, numChannels in
            let requestedElementsNum = Int(numFrames * numChannels)

            var array: Array<Float> = Array(repeating: 0.0, count: requestedElementsNum)

            guard self.state == .playing else {
                data?.initialize(from: &array, count: requestedElementsNum)
                return
            }
            print("dstest output frames number: \(numFrames) (\(self.dataArray.count)) \(requestedElementsNum)")

            let elementsNum = min(requestedElementsNum, self.dataArray.count)
            array.removeAll()
            array.append(contentsOf: self.dataArray[0..<elementsNum])

            data?.initialize(from: &array, count: requestedElementsNum)
            self.dataArray.removeFirst(elementsNum)

            if self.dataArray.isEmpty {
                self.audioManager.pause()
                self.state = .idle
                print("dstest stop playing")
            }

        }
    }

    func tryIt() {
        guard self.state == .idle else {return}
        print("dstest start recording")

        self.dataArray.removeAll()

//        for i in 0..<48000*3
//        {
//            let t = Float(i)/48000.0
//            self.dataArray.append(sin((2 * .pi * 1000.0 * t)))
//        }

        self.queue.async {[unowned self] in
            self.queue.asyncAfter(deadline: .now() + .seconds(1)) {[unowned self] in
                print("dstest start playing")
                self.state = .playing
            }
            self.state = .recording
            self.audioManager.play()

        }

//        self.queue.async {
//            AudioTest.try()
//        }
    }
}
