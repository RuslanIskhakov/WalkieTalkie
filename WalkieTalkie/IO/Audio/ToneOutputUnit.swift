//
//  ToneOutputUnit.swift
//
//  This is a Swift 3 class (which should be instantiated as a singleton object)
//    that can play a single tone of arbitrary tone and frequency on iOS devices
//    using run-time sinewave synthesis and the Audio Unit v3 API with RemoteIO.
//
//  Created by Ronald Nicholson  rhn@nicholson.com  on 2/20/2016.
//    revised 2016-Sep-08 for Swift 3
//  http://www.nicholson.com/rhn/
//  Copyright © 2016 Ronald H Nicholson, Jr. All rights reserved.
//  Distribution: BSD 2-clause license
//
import Foundation
import AudioUnit
import AVFoundation

final class ToneOutputUnit: NSObject {

    var auAudioUnit: AUAudioUnit! = nil     // placeholder for RemoteIO Audio Unit

    var avActive     = false             // AVAudioSession active flag
    var audioRunning = false             // RemoteIO Audio Unit running flag

    var sampleRate : Double = 44100.0    // typical audio sample rate

    var f0  =    880.0              // default frequency of tone:   'A' above Concert A
    var v0  =  16383.0              // default volume of tone:      half full scale

    var toneCount : Int32 = 0       // number of samples of tone to play.  0 for silence

    private var phY =     0.0       // save phase of sine wave to prevent clicking
    private var interrupted = false     // for restart from audio interruption notification

    var samples = Array<Int16>()

    func startToneForDuration(time : Double) {
        if audioRunning {                    // make sure to call enableSpeaker() first
            if toneCount == 0 {         // only play a tone if the last tone has stopped
                toneCount = Int32(round( time / sampleRate ))
            }
        }
    }

    func setFrequency(freq : Double) {  // audio frequencies below 500 Hz may be
        f0 = freq                       //   hard to hear from a tiny iPhone speaker.
    }

    func setToneVolume(vol : Double) {  // 0.0 to 1.0
        v0 = vol * 32766.0
    }

    func setToneTime(t : Int) {
        toneCount = Int32(t);
    }

    func start() {

        if audioRunning { return }           // return if RemoteIO is already running

        if (avActive == false) {

            do {        // set and activate Audio Session

                let audioSession = AVAudioSession.sharedInstance()

                try audioSession.setCategory(AVAudioSession.Category.playback) // play and record

//                if let availableInputs = audioSession.availableInputs,
//                      let builtInMicInput = availableInputs.first(where: { $0.portType == .builtInMic })
//                {
//                    do {
//                        try audioSession.setPreferredInput(builtInMicInput)
//                    } catch {
//                        print("dstest Unable to set the built-in mic as the preferred input.")
//                    }
//                }

                var preferredIOBufferDuration = 4.0 * 0.0058      // 5.8 milliseconds = 256 samples
                let hwSRate = audioSession.sampleRate           // get native hardware rate
                if hwSRate == 48000.0 { sampleRate = 48000.0 }  // set session to hardware rate
                if hwSRate == 48000.0 { preferredIOBufferDuration = 4.0 * 0.0053 }
                let desiredSampleRate = sampleRate
                print("dstest2 samplerate 2: \(sampleRate)")
                try audioSession.setPreferredSampleRate(desiredSampleRate)
                try audioSession.setPreferredIOBufferDuration(preferredIOBufferDuration)

                NotificationCenter.default.addObserver(
                    forName: AVAudioSession.interruptionNotification,
                    object: nil,
                    queue: nil,
                    using: myAudioSessionInterruptionHandler )

                try audioSession.setActive(true)
                avActive = true
            } catch /* let error as NSError */ {
                // handle error (audio system broken?)
            }
        }


        do {        // not running, so start hardware

            let audioComponentDescription = AudioComponentDescription(
                componentType: kAudioUnitType_Output,
                componentSubType: kAudioUnitSubType_RemoteIO,
                componentManufacturer: kAudioUnitManufacturer_Apple,
                componentFlags: 0,
                componentFlagsMask: 0 )

            if (auAudioUnit == nil) {

                try auAudioUnit = AUAudioUnit(componentDescription: audioComponentDescription)

                let bus0 = auAudioUnit.inputBusses[0]

                let audioFormat = AVAudioFormat(
                    commonFormat: AVAudioCommonFormat.pcmFormatInt16,   // short int samples
                    sampleRate: Double(sampleRate),
                    channels:AVAudioChannelCount(1),
                    interleaved: true )                                 // interleaved stereo

                try bus0.setFormat(audioFormat!)  //      for speaker bus

                auAudioUnit.outputProvider = { [unowned self] (    //  AURenderPullInputBlock?
                    actionFlags,
                    timestamp,
                    frameCount,
                    inputBusNumber,
                    inputDataList ) -> AUAudioUnitStatus in

                    //print("dstest samples - 1: \(frameCount)")

//                    let err : OSStatus = self.auAudioUnit.renderBlock (actionFlags,
//                                               timestamp,
//                                               frameCount,
//                                               1,
//                                               inputData,
//                                               .none)
//                    if err == noErr {
//                        // save samples from current input buffer to circular buffer
//                        print("dstest samples - 2: \(frameCount)")
//                    } else {
//                        print("dstest samples - 3: \(frameCount) error: \(err.description)")
//                    }
//                    let err2 : AUAudioUnitStatus = noErr
//                    return err2

                    self.fillSpeakerBuffer(inputDataList: inputDataList, frameCount: frameCount)
                    return(0)
                }

//                auAudioUnit.inputHandler = {[weak self] (
//                    actionFlags,
//                    timestamp,
//                    frameCount,
//                    inputBusNumber)
//                    in
//                    guard let self else { return }
//
//                    print("dstest inputHandler \(frameCount) \(inputBusNumber)")
////                    var bufferList = AudioBufferList(
////                        mNumberBuffers: 1,
////                        mBuffers: AudioBuffer(
////                            mNumberChannels: audioFormat!.channelCount,
////                            mDataByteSize: 0,
////                            mData: nil))
////
////                    let err : OSStatus = self.auAudioUnit.renderBlock (
////                        actionFlags,
////                        timestamp,
////                        frameCount,
////                        inputBusNumber,
////                        &bufferList
////                    ) { (    //  AURenderPullInputBlock?
////                        actionFlags,
////                        timestamp,
////                        frameCount,
////                        inputBusNumber,
////                        inputDataList ) -> AUAudioUnitStatus
////                        in
////
////                        print("dstest from mic")
////
////                        return(0)
////                    }
////                    if err == noErr {
////                        // save samples from current input buffer to circular buffer
////                        print("dstet inputData = \(bufferList.mBuffers.mDataByteSize) and frameCount: \(frameCount)")
//////                            if !self.isMuteState {
//////                                self.recordMicrophoneInputSamples(
//////                                    inputDataList:  &bufferList,
//////                                    frameCount: UInt32(frameCount) )
//////                            }
////                    }
//                }
            }

            auAudioUnit.isOutputEnabled = true
            toneCount   =   0

            try auAudioUnit.allocateRenderResources()  //  v2 AudioUnitInitialize()
            try auAudioUnit.startHardware()            //  v2 AudioOutputUnitStart()
            audioRunning = true

        } catch /* let error as NSError */ {
            // handleError(error, functionName: "AUAudioUnit failed")
            // or assert(false)
        }
    }

    // helper functions

    private func fillSpeakerBuffer(     // process RemoteIO Buffer for output
        inputDataList : UnsafeMutablePointer<AudioBufferList>,
        frameCount : UInt32 )
    {
        let inputDataPtr = UnsafeMutableAudioBufferListPointer(inputDataList)
        let nBuffers = inputDataPtr.count
        if (nBuffers > 0) {

            let mBuffers : AudioBuffer = inputDataPtr[0]
            let count = Int(frameCount)

            // Speaker Output == play tone at frequency f0
            if (   self.v0 > 0)
                && (self.toneCount > 0 )
            {
                // audioStalled = false

                let sz = Int(mBuffers.mDataByteSize)

                let bufferPointer = UnsafeMutableRawPointer(mBuffers.mData)
                if var bptr = bufferPointer {
                    for i in 0..<(count) {
                        let x = self.samples[index]
                        index += 1
                        if index >= samples.count {index = 0}

                        if (i < (sz / 2)) {
                            bptr.assumingMemoryBound(to: Int16.self).pointee = x
                            bptr += 2   // increment by 2 bytes for next Int16 item
//                            bptr.assumingMemoryBound(to: Int16.self).pointee = x
//                            bptr += 2   // stereo, so fill both Left & Right channels
                        }
                    }
                }

                self.toneCount  -=  Int32(frameCount)   // decrement time remaining
            } else {
                // audioStalled = true
                memset(mBuffers.mData, 0, Int(mBuffers.mDataByteSize))  // silence
            }
        }
    }

    private var index = 0

    func stop() {
        if (audioRunning) {
            auAudioUnit.stopHardware()
            audioRunning = false
        }
        if (avActive) {
            let audioSession = AVAudioSession.sharedInstance()
            do {
                // try audioSession.setActive(false)
            } catch {
            }
            // avActive = false
        }
    }

    private func myAudioSessionInterruptionHandler( notification: Notification ) -> Void {
        let interuptionDict = notification.userInfo
        if let interuptionType = interuptionDict?[AVAudioSessionInterruptionTypeKey] {
            let interuptionVal = AVAudioSession.InterruptionType(
                rawValue: (interuptionType as AnyObject).uintValue )
            if (interuptionVal == AVAudioSession.InterruptionType.began) {
                if (audioRunning) {
                    auAudioUnit.stopHardware()
                    audioRunning = false
                    interrupted = true
                }
            }
        }
    }
}

//  end of the ToneOutputUnit class
