//
//  AudioModel.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 12.11.2022.
//

import RxRelay

class AudioModel: BaseModelInitialisable, AudioModelProtocol {

    weak var appModel: AppModelProtocol?

    var wkState = BehaviorRelay<WalkieTalkieState>(value: .idle)

    private let queue = DispatchQueue(label: "AudioModel", qos: .utility)

    private var audioSessionManager: AudioSessionManager?
    private var audioTransforms: AudioTransforms?

    override init() {
        super.init()
        let audioTransforms = AudioTransforms() {[unowned self] () -> WalkieTalkieState in
            return self.wkState.value
        }
        self.audioTransforms = audioTransforms
        self.audioSessionManager = AudioSessionManager(with: audioTransforms)
    }

    func tryIt() {
        self.queue.async {[unowned self] in
            self.audioSessionManager?.start()
        }

    }
}
