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
let SamplingRate = 44100

class TapeRecorder : NSObject {
    
    fileprivate var mic : AKMicrophone?
    fileprivate var recorder : AKNodeRecorder?
    
    fileprivate var locator = Locator()
    
    private var _durationRecorded = 0.0
    
    var durationRecorded : Double {
        return _durationRecorded
    }
    
    var task : RecordTapeTask?
    
    var currentRecording : Recording!
    
    override init() {
        super.init()
        locator.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(_:)), name: NSNotification.Name.AVAudioSessionInterruption, object: nil)
    }
    
    deinit {
        //Remove from Recieving Notification when dealloc'd
        NotificationCenter.default.removeObserver(self)
        
        mic = nil
        recorder = nil
    }
    
    func requestPermission(handler: @escaping (Bool)->Void){
        AKSettings.session.requestRecordPermission(handler)
    }
    
    
    func prepareRecording()  throws -> RecordTapeTask {
        
        
        do {
            try AKSettings.setSession(category: .record, with: .mixWithOthers)
            AKSettings.audioInputEnabled = true
            
        } catch {
            throw error
        }
        
        self.currentRecording = ResourceManager.manager.createRecording()
        
        locator.getLocation()
        
        
        
        let settings = [AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
                        AVEncoderBitRateKey: 16,
                        AVNumberOfChannelsKey: 1,
                        AVSampleRateKey: Double(SamplingRate),
                        AVFormatIDKey:Int(kAudioFormatMPEG4AAC)] as [String : Any]
        
        self.mic = AKMicrophone()
        
        let recordUrl = ResourceManager.getRecordingURL(id: self.currentRecording.id!)
        
        do {
            let audioFile = try AKAudioFile(forWriting: recordUrl, settings: settings)
            self.recorder = try AKNodeRecorder(node: mic, file: audioFile)
        } catch {
            throw error
        }
        
        
        
        
        task = RecordTapeTask(recorder: self)
        return self.task!
    }
    
    func startRecording(){
        
    }
    
    
    func stopRecording(){
        recorder?.stop()
        task?.stop(.stop)
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
extension TapeRecorder : LocatorDelegate {
    
    /// Update of user's lastest location
    ///
    /// - Parameter:
    ///   - location: Best last Location
    func locator(didUpdateBestLocation location: CLLocation) {
        
    }

    /// Update of user's lastest location failed
    ///
    /// - Parameter:
    ///   - error: Error trying to get user's last location
    func locator(didFailWithError error: Error) {
        
    }

    /// Present Alert due to lack of permission or error
    ///
    /// - Parameter alert: Alert
    func presentAlert(_ alert: UIViewController) {
        
    }

    
    
}


