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

    private var timer: Timer?

    override init() {
        super.init()
        let audioTransforms = AudioTransforms(delegate: self)

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
                    self.setupRxEndTimeout()
                    self.audioSessionManager?.start()
                }
            }).disposed(by: self.disposeBag)
    }

    private func setupRxEndTimeout() {
        self.timer?.invalidate()
        DispatchQueue.main.async {[weak self] in
            guard let self else { return }
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: {[weak self] timer in
                guard let self else { return }
                self.wkState.accept(.idle)
            })
        }
    }

    func receivedSamples(_ samples: Array<SampleFormat>) {
        self.wkState.accept(.receiving)
        self.audioTransforms?.receivedSamples(samples)
    }
}

extension AudioModel: AudioTransformsDelegate {
    func getStatus() -> WalkieTalkieState { self.wkState.value }

    func sendSamples(_ buffer: CircledSamplesBuffer<SampleFormat>) {
        self.appModel?.clientModel.sendData(buffer)
    }
}
