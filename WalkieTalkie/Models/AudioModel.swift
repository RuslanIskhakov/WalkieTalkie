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

    private var state: AudioState = .idle

    init() {

    }

    private var recorder = RecordAudio_v2()
    private var toneOutputUnit = ToneOutputUnit()

    func tryIt() {

//        let toneOutputUnit = ToneOutputUnit()
//        toneOutputUnit.start()
//        toneOutputUnit.setFrequency(freq: 1000)
//        toneOutputUnit.setToneTime(t: 2)


        self.queue.async {[unowned self] in
            self.queue.asyncAfter(deadline: .now() + .seconds(2)) {[unowned self] in
                self.recorder.stopRecording()

//                var samples = Array<Int16>()
//                samples.append(contentsOf: self.recorder.circBuffer[0..<self.recorder.circInIdx])
//                samples.append(contentsOf: self.recorder.circBuffer[self.recorder.circInIdx..<self.recorder.circBuffSize])

                print("dstest recorded: \(self.recorder.circInIdx)")

//                let f = Float(1000)
//                for i in 0..<samples.count {
//                    let t: Float = Float(i)/48000
//                    let s = Int16(30000 * sin (2 * .pi * f * t))
//                    samples[i] = s
//
//                }

                self.toneOutputUnit = ToneOutputUnit()
                self.toneOutputUnit.start()
                self.toneOutputUnit.samples = self.recorder.circBuffer
                toneOutputUnit.setToneTime(t: self.recorder.circBuffer.count)

            }
            self.recorder = RecordAudio_v2()
            self.recorder.startRecording()
        }


    }
}
