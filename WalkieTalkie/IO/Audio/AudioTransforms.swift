//
//  AudioTransforms.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 15.11.2022.
//

import Foundation
import CoreAudioTypes
import CoreAudio

typealias SampleFormat = Int16

class AudioTransforms: BaseIOInitialisable, AudioSessionManagerDelegate {

    private let queue = DispatchQueue(label: "AudioTransforms", qos: .utility)

    private weak var delegate: AudioTransformsDelegate?

    var wkState: WalkieTalkieState {return self.delegate?.getStatus() ?? .idle}

    init(
        delegate: AudioTransformsDelegate? = nil
    ) {
        self.delegate = delegate
    }

    // for samples captured from microphone
    private var inputBuffer = CircledSamplesBuffer<SampleFormat>(capacity: 65536)
    // for samples to be played
    private var outputBuffer = CircledSamplesBuffer<SampleFormat>(capacity: 65536)

    func receivedSamples(_ samples: Array<SampleFormat>) {
        self.queue.sync { self.outputBuffer.putSamples(samples) }
    }

    func recordMicrophoneInputSamples(   // process RemoteIO Buffer from mic input
        inputDataList : UnsafeMutablePointer<AudioBufferList>,
        frameCount : UInt32 )
    {
        let inputDataPtr = UnsafeMutableAudioBufferListPointer(inputDataList)
        let mBuffers : AudioBuffer = inputDataPtr[0]

        // Microphone Input Analysis
        let bufferPointer = UnsafeMutableRawPointer(mBuffers.mData)
        if let bptr = bufferPointer {
            let dataArray = bptr.assumingMemoryBound(to: SampleFormat.self)
            for i in 0..<Int(frameCount/mBuffers.mNumberChannels) {
                for ch in 0..<Int(mBuffers.mNumberChannels) {
                    let x = SampleFormat(dataArray[i+ch])   // copy channel sample
                    self.inputBuffer.putSample(x)
                }
            }
            print("Wrote to buffer: \(Int(frameCount/mBuffers.mNumberChannels)) samples")
        }
        self.delegate?.sendSamples(self.inputBuffer)
    }

    func fillSpeakerBuffer(     // process RemoteIO Buffer for output
        inputDataList : UnsafeMutablePointer<AudioBufferList>,
        frameCount : UInt32 )
    {
        let inputDataPtr = UnsafeMutableAudioBufferListPointer(inputDataList)
        let nBuffers = inputDataPtr.count
        if (nBuffers > 0) {

            let mBuffers : AudioBuffer = inputDataPtr[0]
            let count = Int(frameCount)

            let sz = Int(mBuffers.mDataByteSize)

            let bufferPointer = UnsafeMutableRawPointer(mBuffers.mData)
            if var bptr = bufferPointer {
                for i in 0..<(count) {
                    if (i < (sz / 2)) {
                        self.queue.sync {
                            let x = self.outputBuffer.getSample() ?? 0
                            bptr.assumingMemoryBound(to: SampleFormat.self).pointee = x
                            bptr += 2   // increment by 2 bytes for next Int16 item
                        }
                    }
                }
                print("Read from buffer: \(count) samples")
            }
        }
    }
}
