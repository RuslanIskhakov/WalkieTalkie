//
//  AudioSessionManager.swift
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

final class AudioSessionManager: BaseIOInitialisable {

    var auAudioUnit: AUAudioUnit! = nil     // placeholder for RemoteIO Audio Unit

    var avActive     = false             // AVAudioSession active flag
    var audioRunning = false             // RemoteIO Audio Unit running flag

    var sampleRate : Double = 48000.0    // typical audio sample rate

    private var interrupted = false     // for restart from audio interruption notification
    private var audioSessionInterruptionObserver: NSObjectProtocol? = nil

    private weak var delegate: AudioSessionManagerDelegate?

    init(with delegate: AudioSessionManagerDelegate? = nil) {
        self.delegate = delegate
    }

    func start() {

        if audioRunning { return }           // return if RemoteIO is already running

        if (avActive == false) {

            do {        // set and activate Audio Session

                let audioSession = AVAudioSession.sharedInstance()

                try audioSession.setCategory(
                    AVAudioSession.Category.playAndRecord,  // play and record
                    options: [.allowBluetooth, .defaultToSpeaker]
                )

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

                self.audioSessionInterruptionObserver = NotificationCenter.default.addObserver(
                    forName: AVAudioSession.interruptionNotification,
                    object: self,
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

                    guard self.delegate?.wkState == .receiving else { return (0)}

                    self.delegate?.fillSpeakerBuffer(inputDataList: inputDataList, frameCount: frameCount)
                    return (0)
                }

                auAudioUnit.inputHandler = {[unowned self]
                    (actionFlags, timestamp, frameCount, inputBusNumber) in

                    guard self.delegate?.wkState == .transmitting else { return }

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
                        self.delegate?.recordMicrophoneInputSamples(
                            inputDataList:  &bufferList,
                            frameCount: UInt32(frameCount) )
                    }

                }
            }

            auAudioUnit.isOutputEnabled = true
            auAudioUnit.isInputEnabled = true

            try auAudioUnit.allocateRenderResources()  //  v2 AudioUnitInitialize()
            try auAudioUnit.startHardware()            //  v2 AudioOutputUnitStart()
            audioRunning = true

        } catch /* let error as NSError */ {
            // handleError(error, functionName: "AUAudioUnit failed")
            // or assert(false)
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

        if let observer = self.audioSessionInterruptionObserver {
            NotificationCenter.default.removeObserver(observer)
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
