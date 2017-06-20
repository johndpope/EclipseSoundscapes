//
//  TapeRecorder.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 5/31/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import CoreLocation
import UIKit
import AVFoundation
import AudioKit

protocol RecordingDelegate: NSObjectProtocol {
    func progress(_ progress: Double)
    func failed(withError error : AudioError)
    func finished(_ recording: Recording)
    func paused()
    func resumed()
}

/// Handles operations for Recording Audio
public class TapeRecorder : NSObject {
    
    weak var delegate : RecordingDelegate?
    
//    /// Phone's Microphone
//    private var mic : AKMicrophone!
    
    /// Recorder
    private var recorder : AVAudioRecorder!
    
    /// Location of User
    private var location : CLLocation!
    
    /// Recording during a recording operation
    private var currentRecording : Recording!
    
    /// Local Timer to update duration
    fileprivate var timer : Timer?
    
    var progress : Double = 0.0
    
    /// Settings to configure the record audio
    private var settings = [AVNumberOfChannelsKey: 1,
                           AVSampleRateKey: 44100,
                           AVLinearPCMBitDepthKey:16,
                           AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue,
                           AVFormatIDKey: kAudioFormatMPEG4AAC,
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
        recorder = nil
    }
    
    /// Request Permission from the User to use the microphone to record audio
    /// - Important: Alert will be non-nil only if the user has denied the Recording Permission
    /// - Parameter handler: Bool containing wether the user has granted permission or not
    func requestPermission(handler: @escaping (Bool, UIAlertController?) -> Void) {
        let permission = AKSettings.session.recordPermission()
        
        switch permission {
        case AVAudioSessionRecordPermission.granted:
            handler(true, nil)
            return
        case AVAudioSessionRecordPermission.denied:
            let alert = UIAlertController.appSettingsAlert(title: "Recording Permission Denied", message: "Turn on Location in Settings > EclipseSignal > Microphone to allow us to record your eclipse experience")
            handler(false, alert)
            break
        default:
            break
        }
        
        AKSettings.session.requestRecordPermission { (granted) in
                handler(granted, nil)
        }
    }
    
    /// Initalize all the components in order to record
    ///
    /// - Returns: Record Monitor to manage the recording operation
    /// - Throws: Error while trying to configure the Audio session or build the recorder
    func prepareRecording() throws {
        
        do {
            if #available(iOS 10.0, *) {
                try AKSettings.setSession(category: .playAndRecord, with: .allowBluetoothA2DP)
            } else {
                // Fallback on earlier versions
                try AKSettings.setSession(category: .playAndRecord, with: .allowBluetooth)
            }
            AKSettings.audioInputEnabled = true
            AudioKit.start()
            
            self.currentRecording = ResourceManager.manager.createRecording()
            ResourceManager.manager.setLocation(recording: self.currentRecording, location: self.location.coordinate, shouldSave: true)
            
            let audioFile = ResourceManager.recordingURL(id: self.currentRecording.id!)
            
            self.recorder = try AVAudioRecorder(url: audioFile, settings: settings)
            
            progress = 0.0
            
        } catch {
            throw error
        }
        
    }
    
    /// Start the Recorder
    func record() throws {
        
        do {
            try self.prepareRecording()
            self.recorder.record()
            
            self.delegate?.progress(self.progress)
            
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        } catch {
            throw error
        }
    }
    
    /// Update the duration of the current monitor session to the tapeRecorder's duration and fire progress events
    @objc private func updateProgress() {
        
        self.progress = self.recorder.currentTime
        print(String.init(format: "Recording duration: %.2f", self.progress))
        
        self.delegate?.progress(self.progress)
        
        if self.progress >= RecordingDurationMax {
            self.stop(.success, error: nil)
        }
        
    }
    
    /// Stop the monitor and the recorder with a status
    ///
    /// - Parameters:
    ///   - status: Reason why the monitor was stopped
    ///   - error: Error involed with the stopage
    public func stop(_ status: AudioStatus, error: AudioError?) {
        timer?.invalidate()
        if recorder.isRecording {
            recorder.stop()
        }
        AudioKit.stop()
        guard error == nil else {
            self.delegate?.failed(withError: error!)
            deleteRecording()
            return
        }
        switch status {
        case .interruption: //TODO: Have some way to mark track if there was an interruption
            break
        case .success:
            self.recordingFinished()
            break
        case .cancel:
            if self.progress <= RecordingDurationMin {
                self.delegate?.failed(withError: AudioError.tooShort)
                self.deleteRecording()
            } else {
                self.recordingFinished()
            }
            break
        default:
            break
        }
        
    }
    
    /// Pause the Recorder
    public func pause() {
        if recorder.isRecording {
            if timer?.isValid ?? true {
                timer?.invalidate()
            }
            recorder.pause()
            print("Recorder Paused")
        }
        self.delegate?.paused()
        AudioKit.stop()
    }
    
    /// Resume the Recorder
    public func resume() {
        AudioKit.start()
        if !recorder.isRecording {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
            recorder.record()
            print("Recorder Resumed")
        }
        self.delegate?.resumed()
    }
    
    /// Handle the passing of the current tapeRecorder's recordings after a successful session
    private func recordingFinished() {
        ResourceManager.manager.instertRecording(recording: self.currentRecording, info: [Recording.DURATION: self.progress])
        
        self.delegate?.finished(self.currentRecording)
        
    }
    
    /// Delete the current session's recording if the session ended with an Error
    private func deleteRecording() {
        recorder.deleteRecording()
    }
}
extension TapeRecorder {
    /// Interruption Handler
    ///
    /// - Parameter notification: Device generated notification about interruption
    @objc fileprivate func handleInterruption(_ notification: Notification) {
        let theInterruptionType = (notification as NSNotification).userInfo![AVAudioSessionInterruptionTypeKey] as! UInt
        NSLog("Session interrupted > --- %@ ---\n", theInterruptionType == AVAudioSessionInterruptionType.began.rawValue ? "Begin Interruption" : "End Interruption")
        
        if theInterruptionType == AVAudioSessionInterruptionType.began.rawValue {
            //Interruption Started
            self.pause()
        }
        
        if theInterruptionType == AVAudioSessionInterruptionType.ended.rawValue {
            //Interruption Ended
            self.resume()
        }
    }
}

extension TapeRecorder : AVAudioRecorderDelegate {
    public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        guard let encodingError = error else {
            self.stop(.error, error: AudioError.unkown)
            return
        }
        self.stop(.error, error: AudioError.system(encodingError))
    }
    
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        print(flag ? "Recoreder did Finish Fine" : "Recorder finised due to an encoding error")
    }
}
