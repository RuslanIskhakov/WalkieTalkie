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

    private let recorder = RecordAudio()

    func tryIt() {

//        let toneOutputUnit = ToneOutputUnit()
//        toneOutputUnit.start()
//        toneOutputUnit.setFrequency(freq: 1000)
//        toneOutputUnit.setToneTime(t: 2)


        self.queue.async {[unowned self] in
            self.queue.asyncAfter(deadline: .now() + .seconds(2)) {[unowned self] in
                self.recorder.stopRecording()
            }
            self.recorder.startRecording()
        }


    }
}
