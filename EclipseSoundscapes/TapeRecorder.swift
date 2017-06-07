//
//  TapeRecorder.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 5/31/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import Foundation
import CoreLocation
import AudioKit





/// Handles operations for Recording Audio
public class TapeRecorder : NSObject, AVAudioRecorderDelegate {
    
    
    /// Phone's Microphone
    private var mic : AKMicrophone!
    
    /// Recorder
    private var recorder : AVAudioRecorder?
    
    /// Location of User
    private var location : CLLocation!
    
    /// Monitor for recording operation
    private var monitor : RecordTapeMonitor?
    
    
    /// Recording during a recording operation
    private var currentRecording : Recording!
    
    /// Settings to configure the record audio
    private var settings = [AVNumberOfChannelsKey: 1,
                           AVSampleRateKey: 44100,
                           AVLinearPCMBitDepthKey:16,
                           AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue,
                           AVFormatIDKey: kAudioFormatMPEG4AAC,
                           AVEncoderBitRateKey: 196000,
                           AVLinearPCMIsNonInterleaved: false
        ] as [String : Any]
    
    init(location : CLLocation) {
        super.init()
        self.location = location
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(_:)), name: NSNotification.Name.AVAudioSessionInterruption, object: nil)
    }
    
    deinit {
        //Remove from Recieving Notification when dealloc'd
        NotificationCenter.default.removeObserver(self)
        location = nil
        monitor = nil
        mic = nil
        recorder = nil
    }
    
    /// Request Permission from the User to use the microphone to record audio
    /// - Important: Alert will be non-nil only if the user has denied the Recording Permission
    /// - Parameter handler: Bool containing wether the user has granted permission or not
    func requestPermission(handler: @escaping (Bool, UIAlertController?)->Void){
        let permission = AKSettings.session.recordPermission()
        
        
        switch permission {
        case AVAudioSessionRecordPermission.granted:
            handler(true, nil)
            break
        case AVAudioSessionRecordPermission.denied:
            let alert = UIAlertController.appSettingsAlert(title: "Recording Permission Denied", message: "Turn on Location in Settings > EclipseSignal > Microphone to allow us to record your eclipse experience")
            handler(false, alert)
            break
        default:
            break
        }
        
        AKSettings.session.requestRecordPermission { (granted) in
            DispatchQueue.main.async {
                handler(granted, nil)
            }
        }
    }
    
    
    /// Initalize all the components in order to record
    ///
    /// - Returns: Record Monitor to manage the recording operation
    /// - Throws: Error while trying to configure the Audio session or build the recorder
    func prepareRecording()  throws -> RecordTapeMonitor {
        
        do {
            try AKSettings.setSession(category: .playAndRecord, with: .allowBluetoothA2DP)
            AKSettings.audioInputEnabled = true
            mic = AKMicrophone()
            AudioKit.start()
            
            
            self.currentRecording = ResourceManager.manager.createRecording()
            ResourceManager.manager.setLocation(recording: self.currentRecording, location: self.location.coordinate, shouldSave: true)
            
            let audioFile = ResourceManager.recordingURL(id: self.currentRecording.id!)
            
            self.recorder = try AVAudioRecorder(url: audioFile, settings: settings)
            monitor = RecordTapeMonitor(recorder: self.recorder!, currentRecording)
            
            monitor?.start()
            
        } catch {
            throw error
        }
        
        return self.monitor!
    }
    
    public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        guard let encodingError = error else {
            monitor?.stop(.error, error: AudioError.unkown)
            return
        }
        monitor?.stop(.error, error: AudioError.system(encodingError))
    }
    
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        print(flag ? "Recoreder did Finish Fine" : "Recorder finised due to an encoding error")
    }
    
    

    /// Interruption Handler
    ///
    /// - Parameter notification: Device generated notification about interruption
    @objc fileprivate func handleInterruption(_ notification: Notification) {
        let theInterruptionType = (notification as NSNotification).userInfo![AVAudioSessionInterruptionTypeKey] as! UInt
        NSLog("Session interrupted > --- %@ ---\n", theInterruptionType == AVAudioSessionInterruptionType.began.rawValue ? "Begin Interruption" : "End Interruption")
        
        if theInterruptionType == AVAudioSessionInterruptionType.began.rawValue {
            //Interruption Started
            self.monitor?.pause()
        }
        
        if theInterruptionType == AVAudioSessionInterruptionType.ended.rawValue {
            //Interruption Ended
            self.monitor?.resume()
        }
    }
    
}


