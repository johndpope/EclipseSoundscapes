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

@objc public enum AudioStatus : Int{
    case sucess
    case error
    case interruption
    case stop
}

enum AudioError: Error {
    
    case permissionDenied
    case interruption
    case unknown(Error)
}

let FileType = ".m4a"
let ExportFileType = AKAudioFile.ExportFormat.m4a
let SamplingRate = 44100
let RecordingDurationMAX = 30.0//300 5-Minute Max

class TapeRecorder : NSObject, AVAudioRecorderDelegate {
    
    let mic : AKMicrophone = AKMicrophone()
    var recorder : AVAudioRecorder?
    
    
    var durationRecorded : Double {
        guard let duration = recorder?.currentTime else {
            return 0.0
        }
        return duration
    }
    
    var location : CLLocation!
    
    var task : RecordTapeTask?
    
    var currentRecording : Recording!
    
    private var settings = [AVNumberOfChannelsKey: 1,
                           AVSampleRateKey: SamplingRate,
                           AVLinearPCMBitDepthKey:16,
                           AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue,
                           AVFormatIDKey: kAudioFormatMPEG4AAC,
                           AVEncoderBitRateKey: 196000,
                           AVLinearPCMIsNonInterleaved: false
        ] as [String : Any]
    
    init(location : CLLocation) {
        self.location = location
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(_:)), name: NSNotification.Name.AVAudioSessionInterruption, object: nil)
    }
    
    deinit {
        //Remove from Recieving Notification when dealloc'd
        NotificationCenter.default.removeObserver(self)
        
//        mic = nil
        recorder = nil
    }
    
    func requestPermission(handler: @escaping (Bool)->Void){
        AKSettings.session.requestRecordPermission { (granted) in
            DispatchQueue.main.async {
                handler(granted)
            }
        }
    }
    
    
    func prepareRecording()  throws -> RecordTapeTask {
        
        do {
            try AKSettings.setSession(category: .playAndRecord, with: .allowBluetoothA2DP)
            AKSettings.audioInputEnabled = true
            AudioKit.start()
            
            
            self.currentRecording = ResourceManager.manager.createRecording()
            ResourceManager.manager.setLocation(recording: self.currentRecording, location: self.location.coordinate, shouldSave: true)
            
            let audioFile = ResourceManager.getRecordingURL(id: self.currentRecording.id!)
            
            self.recorder = try AVAudioRecorder(url: audioFile, settings: settings)
            task = RecordTapeTask(recorder: self)
            
            task?.start()
            
        } catch {
            throw error
        }
        
        return self.task!
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("REcoreder did Finish")
    }
    
    

    //TODO: Implement the recording to pause while interruption is in prpogress and restart after interruption is stoped
    
    /// Interruption Handler
    ///
    /// - Parameter notification: Device generated notification about interruption
    @objc fileprivate func handleInterruption(_ notification: Notification) {
        let theInterruptionType = (notification as NSNotification).userInfo![AVAudioSessionInterruptionTypeKey] as! UInt
        NSLog("Session interrupted > --- %@ ---\n", theInterruptionType == AVAudioSessionInterruptionType.began.rawValue ? "Begin Interruption" : "End Interruption")
        
        if theInterruptionType == AVAudioSessionInterruptionType.began.rawValue {
            //Interruption Started
        }
        
        if theInterruptionType == AVAudioSessionInterruptionType.ended.rawValue {
            //Interruption Ended
        }
    }
    
}


