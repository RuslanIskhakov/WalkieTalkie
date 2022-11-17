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

    private var feedbackGenerator = FeedbackGenerator()

    override init() {
        super.init()
        let audioTransforms = AudioTransforms(delegate: self)

        self.audioTransforms = audioTransforms
        self.audioSessionManager = AudioSessionManager(with: audioTransforms)

        self.setupBindings()
    }

    private func setupBindings() {

        // haptic feedback
        self.wkState
            .subscribe(on: SerialDispatchQueueScheduler(qos: .utility))
            .observe(on: SerialDispatchQueueScheduler(qos: .utility))
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self]  _ in
                self.feedbackGenerator.makeFeedback()
            }).disposed(by: self.disposeBag)

        // toggle modes
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
                    self.audioSessionManager?.start()
                }
            }).disposed(by: self.disposeBag)

        // return to idle after receiving timeout
        self.wkState
            .asObservable()
            .subscribe(on: SerialDispatchQueueScheduler(qos: .utility))
            .observe(on: SerialDispatchQueueScheduler(qos: .utility))
            .filter{$0 == .receiving}
            .debounce(
                .milliseconds(1000),
                scheduler: SerialDispatchQueueScheduler(qos: .utility)
            )
            .subscribe(onNext: {value in
                self.queue.async { [unowned self] in
                    self.wkState.accept(.idle)
                }
            }).disposed(by: self.disposeBag)

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
