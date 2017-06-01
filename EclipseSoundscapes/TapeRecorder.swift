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

let FileType = ".caf"
let ExportFileType = AKAudioFile.ExportFormat.m4a
let SamplingRate = 44100

class TapeRecorder : NSObject {
    
    var mic : AKMicrophone?
    var recorder : AKNodeRecorder?
    
    
    var durationRecorded : Double {
        guard let duration = recorder?.recordedDuration else {
            return 0.0
        }
        return duration
    }
    
    var location : CLLocation!
    
    var task : RecordTapeTask?
    
    var currentRecording : Recording!
    
    init(location : CLLocation) {
        self.location = location
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(_:)), name: NSNotification.Name.AVAudioSessionInterruption, object: nil)
    }
    
    deinit {
        //Remove from Recieving Notification when dealloc'd
        NotificationCenter.default.removeObserver(self)
        
        mic = nil
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
            
        } catch {
            throw error
        }
        
        self.currentRecording = ResourceManager.manager.createRecording()
        ResourceManager.manager.setLocation(recording: self.currentRecording, location: self.location.coordinate, shouldSave: true)
    
        
        let settings = [AVNumberOfChannelsKey: 1,
                        AVSampleRateKey: SamplingRate,
                        AVLinearPCMBitDepthKey:16,
                        AVEncoderBitRateKey:196000,
                        AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
                        ] as [String : Any]
        
        self.mic = AKMicrophone()
        
        
        let recordUrl = ResourceManager.getRecordingURL(id: self.currentRecording.id!)
        do {
            let audioFile = try AKAudioFile(forWriting: recordUrl, settings: settings)
            
            self.recorder = try AKNodeRecorder(node: mic, file: audioFile)
            
        } catch {
            throw error
        }
        
        task = RecordTapeTask(recorder: self)
        AudioKit.start()
        task?.start()
        
        return self.task!
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


