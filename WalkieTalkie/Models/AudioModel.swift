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

    private var audioProcessor = AudioProcessor()

    func tryIt() {

        self.queue.async {[unowned self] in
            audioProcessor.start()
        }

    }
}
