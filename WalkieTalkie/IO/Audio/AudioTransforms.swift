//
//  AudioTransforms.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 15.11.2022.
//

import Foundation
import CoreAudioTypes
import CoreAudio

class AudioTransforms: BaseIOInitialisable, AudioSessionManagerDelegate {

    private var callback: (() -> WalkieTalkieState)? = nil

    var wkState: WalkieTalkieState {return self.callback?() ?? .idle}

    init(with callback: (() -> WalkieTalkieState)?) {
        self.callback = callback
    }

    // for samples captured from microphone
    private var inputBuffer = CircledSamplesBuffer<Int16>(capacity: 65536)
    // for samples to be played
    private var outputBuffer = CircledSamplesBuffer<Int16>(capacity: 65536)

    func recordMicrophoneInputSamples(   // process RemoteIO Buffer from mic input
        inputDataList : UnsafeMutablePointer<AudioBufferList>,
        frameCount : UInt32 )
    {
        let inputDataPtr = UnsafeMutableAudioBufferListPointer(inputDataList)
        let mBuffers : AudioBuffer = inputDataPtr[0]

        // Microphone Input Analysis
        let bufferPointer = UnsafeMutableRawPointer(mBuffers.mData)
        if let bptr = bufferPointer {
            let dataArray = bptr.assumingMemoryBound(to: Int16.self)
            for i in 0..<Int(frameCount/mBuffers.mNumberChannels) {
                for ch in 0..<Int(mBuffers.mNumberChannels) {
                    let x = Int16(dataArray[i+ch])   // copy channel sample
                    self.inputBuffer.putSample(x)
                }
            }
            print("Wrote to buffer: \(Int(frameCount/mBuffers.mNumberChannels)) samples")
        }
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
                    let x = self.outputBuffer.getSample()
                    if (i < (sz / 2)) {
                        bptr.assumingMemoryBound(to: Int16.self).pointee = x
                        bptr += 2   // increment by 2 bytes for next Int16 item
                    }
                }
                print("Read from buffer: \(count) samples")
            }
        }
    }
}
