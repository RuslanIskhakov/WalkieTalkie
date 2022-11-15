//
//  AudioModel.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 12.11.2022.
//

import RxRelay
import RxSwift

class AudioModel: BaseModelInitialisable, AudioModelProtocol {

    weak var appModel: AppModelProtocol?

    var wkState = BehaviorRelay<WalkieTalkieState>(value: .idle)

    private let queue = DispatchQueue(label: "AudioModel", qos: .utility)

    private var audioSessionManager: AudioSessionManager?
    private var audioTransforms: AudioTransforms?

    override init() {
        super.init()
        let audioTransforms = AudioTransforms(
            statusCallback: { [unowned self] () -> WalkieTalkieState in
                return self.wkState.value
            },
            sendCallback: { [unowned self] circledSamplesBuffer in
                self.appModel?.clientModel.sendData(circledSamplesBuffer)
            }
        )

        self.audioTransforms = audioTransforms
        self.audioSessionManager = AudioSessionManager(with: audioTransforms)

        self.setupBindings()
    }

    private func setupBindings() {
        self.wkState
            .subscribe(on: SerialDispatchQueueScheduler(qos: .utility))
            .observe(on: SerialDispatchQueueScheduler(qos: .utility))
            .subscribe(onNext: { state in
                switch state {
                case .idle:
                    self.queue.async { [unowned self] in
                        self.appModel?.clientModel.stopClient()
                        self.audioSessionManager?.stop()
                    }
                case .transmitting:
                    self.queue.async { [unowned self] in
                        self.audioSessionManager?.start()
                        self.appModel?.clientModel.startClient()
                    }
                case .receiving:
                    break
                }
            }).disposed(by: self.disposeBag)
    }
}
