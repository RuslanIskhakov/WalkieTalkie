//
//  AudioProcessor.swift
//
//
//  Based on code: https://gist.github.com/hotpaw2
//  by Ronald Nicholson  rhn@nicholson.com
//  http://www.nicholson.com/rhn/
//  Copyright © 2016 Ronald H Nicholson, Jr. All rights reserved.
//
import Foundation
import AudioUnit
import AVFoundation

final class AudioProcessor: BaseIOInitialisable {

    var auAudioUnit: AUAudioUnit! = nil     // placeholder for RemoteIO Audio Unit

    var avActive     = false             // AVAudioSession active flag
    var audioRunning = false             // RemoteIO Audio Unit running flag

    var sampleRate : Double = 48000.0    // typical audio sample rate

    var f0  =    880.0              // default frequency of tone:   'A' above Concert A
    var v0  =  16383.0              // default volume of tone:      half full scale

    var toneCount : Int32 = 0       // number of samples of tone to play.  0 for silence

    private var phY =     0.0       // save phase of sine wave to prevent clicking
    private var interrupted = false     // for restart from audio interruption notification

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

        self.index = 0
        self.index2 = 0

        if (avActive == false) {

            do {        // set and activate Audio Session

                let audioSession = AVAudioSession.sharedInstance()

                try audioSession.setCategory(AVAudioSession.Category.playAndRecord) // play and record

//                if let availableInputs = audioSession.availableInputs,
//                      let builtInMicInput = availableInputs.first(where: { $0.portType == .builtInMic })
//                {
//                    do {
//                        try audioSession.setPreferredInput(builtInMicInput)
//                    } catch {
//                        print("dstest Unable to set the built-in mic as the preferred input.")
//                    }
//                }

                var preferredIOBufferDuration = 0.0053      // 5.8 milliseconds = 256 samples

                try audioSession.setPreferredSampleRate(sampleRate)
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
                // bus 1 is for data that the microphone exports out to the handler block
                let bus1 = auAudioUnit.outputBusses[1]

                let audioFormat = AVAudioFormat(
                    commonFormat: AVAudioCommonFormat.pcmFormatInt16,   // short int samples
                    sampleRate: Double(sampleRate),
                    channels:AVAudioChannelCount(1),
                    interleaved: true )                                 // interleaved stereo

                try bus0.setFormat(audioFormat!)  //      for speaker bus
                try bus1.setFormat(audioFormat!)  //      for microphone bus

                auAudioUnit.outputProvider = { [unowned self] (    //  AURenderPullInputBlock?
                    actionFlags,
                    timestamp,
                    frameCount,
                    inputBusNumber,
                    inputDataList ) -> AUAudioUnitStatus in

                    guard self.index >= self.circBuffer.count else { return (0)}
                    print("dstest samples for playback: \(frameCount)")

                    self.fillSpeakerBuffer(inputDataList: inputDataList, frameCount: frameCount)

                    if self.index2 >= self.circBuffer.count {self.stop()}
                    return (0)
                }

                auAudioUnit.inputHandler = {[unowned self]
                    (actionFlags, timestamp, frameCount, inputBusNumber) in

                    guard self.index < self.circBuffer.count else { return }

                    var bufferList = AudioBufferList(
                        mNumberBuffers: 1,
                        mBuffers: AudioBuffer(
                            mNumberChannels: audioFormat!.channelCount,
                            mDataByteSize: 0,
                            mData: nil))

                    let err : OSStatus = self.auAudioUnit.renderBlock(actionFlags,
                                               timestamp,
                                               frameCount,
                                               inputBusNumber,
                                               &bufferList,
                                               .none)
                    if err == noErr {
                        // save samples from current input buffer to circular buffer
                        self.recordMicrophoneInputSamples(
                            inputDataList:  &bufferList,
                            frameCount: UInt32(frameCount) )
                    }

                }
            }

            auAudioUnit.isOutputEnabled = true
            auAudioUnit.isInputEnabled = true
            toneCount   =   0

            try auAudioUnit.allocateRenderResources()  //  v2 AudioUnitInitialize()
            try auAudioUnit.startHardware()            //  v2 AudioOutputUnitStart()
            audioRunning = true

        } catch /* let error as NSError */ {
            // handleError(error, functionName: "AUAudioUnit failed")
            // or assert(false)
        }
    }

    var circBuffer = [Int16](repeating: 0, count: 100000)
    var index = 0
    var index2 = 0

    // helper functions

    private func recordMicrophoneInputSamples(   // process RemoteIO Buffer from mic input
        inputDataList : UnsafeMutablePointer<AudioBufferList>,
        frameCount : UInt32 )
    {
        let inputDataPtr = UnsafeMutableAudioBufferListPointer(inputDataList)
        let mBuffers : AudioBuffer = inputDataPtr[0]

        // Microphone Input Analysis
        // let data      = UnsafePointer<Int16>(mBuffers.mData)
        let bufferPointer = UnsafeMutableRawPointer(mBuffers.mData)
        if let bptr = bufferPointer {
            let dataArray = bptr.assumingMemoryBound(to: Int16.self)
            var j = self.index
            if j < self.circBuffer.count {
                for i in 0..<Int(frameCount/mBuffers.mNumberChannels) {
                    for ch in 0..<Int(mBuffers.mNumberChannels) {
                        let x = Int16(dataArray[i+ch])   // copy channel sample
                        if j < self.circBuffer.count {self.circBuffer[j+ch] = x}
                    }

                    j += Int(mBuffers.mNumberChannels) ;                // into circular buffer
                }
            }
            print("dstest input frames: \(frameCount)")
            self.index = j              // circular index will always be less than size
        }
    }

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
            if self.v0 > 0
            {
                // audioStalled = false

                let sz = Int(mBuffers.mDataByteSize)

                let bufferPointer = UnsafeMutableRawPointer(mBuffers.mData)
                if var bptr = bufferPointer {
                    for i in 0..<(count) {
                        let x = index2 >= self.circBuffer.count ? 0 : self.circBuffer[index2]
                        index2 += 1

                        if (i < (sz / 2)) {
                            bptr.assumingMemoryBound(to: Int16.self).pointee = x
                            bptr += 2   // increment by 2 bytes for next Int16 item
                        }
                    }
                }

            } else {
                // audioStalled = true
                memset(mBuffers.mData, 0, Int(mBuffers.mDataByteSize))  // silence
            }
        }
    }

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
