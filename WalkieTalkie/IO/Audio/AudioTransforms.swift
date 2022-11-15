//
//  AudioTransforms.swift
//  WalkieTalkie
//
//  Created by Ruslan Iskhakov on 15.11.2022.
//

import Foundation
import CoreAudioTypes

class AudioTransforms: BaseIOInitialisable, AudioSessionManagerDelegate {

    private var callback: (() -> WalkieTalkieState)? = nil

    var wkState: WalkieTalkieState {return self.callback?() ?? .idle}

    init(with callback: (() -> WalkieTalkieState)?) {
        self.callback = callback
    }

    func recordMicrophoneInputSamples(   // process RemoteIO Buffer from mic input
        inputDataList : UnsafeMutablePointer<AudioBufferList>,
        frameCount : UInt32 )
    {
//        let inputDataPtr = UnsafeMutableAudioBufferListPointer(inputDataList)
//        let mBuffers : AudioBuffer = inputDataPtr[0]
//
//        // Microphone Input Analysis
//        // let data      = UnsafePointer<Int16>(mBuffers.mData)
//        let bufferPointer = UnsafeMutableRawPointer(mBuffers.mData)
//        if let bptr = bufferPointer {
//            let dataArray = bptr.assumingMemoryBound(to: Int16.self)
//            var j = self.index
//            if j < self.circBuffer.count {
//                for i in 0..<Int(frameCount/mBuffers.mNumberChannels) {
//                    for ch in 0..<Int(mBuffers.mNumberChannels) {
//                        let x = Int16(dataArray[i+ch])   // copy channel sample
//                        if j < self.circBuffer.count {self.circBuffer[j+ch] = x}
//                    }
//
//                    j += Int(mBuffers.mNumberChannels) ;                // into circular buffer
//                }
//            }
//            print("dstest input frames: \(frameCount)")
//            self.index = j              // circular index will always be less than size
//        }
    }

    func fillSpeakerBuffer(     // process RemoteIO Buffer for output
        inputDataList : UnsafeMutablePointer<AudioBufferList>,
        frameCount : UInt32 )
    {
//        let inputDataPtr = UnsafeMutableAudioBufferListPointer(inputDataList)
//        let nBuffers = inputDataPtr.count
//        if (nBuffers > 0) {
//
//            let mBuffers : AudioBuffer = inputDataPtr[0]
//            let count = Int(frameCount)
//
//            let sz = Int(mBuffers.mDataByteSize)
//
//            let bufferPointer = UnsafeMutableRawPointer(mBuffers.mData)
//            if var bptr = bufferPointer {
//                for i in 0..<(count) {
//                    let x = index2 >= self.circBuffer.count ? 0 : self.circBuffer[index2]
//                    index2 += 1
//
//                    if (i < (sz / 2)) {
//                        bptr.assumingMemoryBound(to: Int16.self).pointee = x
//                        bptr += 2   // increment by 2 bytes for next Int16 item
//                    }
//                }
//            }
//        }
    }
}
