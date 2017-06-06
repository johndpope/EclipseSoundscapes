//
//  TapeMonitor.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 5/31/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import Foundation
import AVFoundation
import AudioKit


/// Monitor Callback contain the session's TapePiece
public typealias TapeCallback = ((TapePiece) -> Void)


/// Status of the Tape during a Monitor Session
///
/// - progress: Monitor progress event
/// - success: Tape has completed successfully
/// - failure: Tape has completed due to an error
/// - pause: Tape was paused
/// - resume: Tape was resumed
public enum MonitorStatus {
    case progress
    case success
    case failure
    case pause
    case resume
}



/// Manages Observation Callbacks throughout Tape Operations
public class TapeMonitor: NSObject {

    override init() {
        super.init()
        
        pauseMaster = Dictionary<String, TapeCallback>()
        resumeMaster = Dictionary<String, TapeCallback>()
        progressMaster = Dictionary<String, TapeCallback>()
        failureMaster = Dictionary<String, TapeCallback>()
        sucessMaster = Dictionary<String, TapeCallback>()
        masterMap = Dictionary<String, MonitorStatus>()
    }
    
    deinit {
        removeAllObservers()
        pauseMaster = nil
        resumeMaster = nil
        progressMaster = nil
        failureMaster = nil
        sucessMaster = nil
        masterMap = nil
    }
    
    /// Container for all Pause Observers
    fileprivate var pauseMaster : Dictionary<String, TapeCallback>!
    
    /// Container for all Resume Observers
    fileprivate var resumeMaster : Dictionary<String, TapeCallback>!
    
    /// Container for all Progress Observers
    fileprivate var progressMaster : Dictionary<String, TapeCallback>!
    
    /// Container for all Failure Observers
    fileprivate var failureMaster : Dictionary<String, TapeCallback>!
    
    /// Container for all Success Observers
    fileprivate var sucessMaster : Dictionary<String, TapeCallback>!
    
    /// Container for Status to Observers
    fileprivate var masterMap : Dictionary<String, MonitorStatus>!
    
    /// Progress of the current Monitor Session
    fileprivate var progress = 0.0
    
    /// Error during the current Monitor Session
    fileprivate var error : AudioError?
    
    
    /// Current status of Tape
    var tapePiece : TapePiece {
        return TapePiece(duration: self.progress, error: error)
    }
    
    
    /// Set Tape Status for the Tape Monitor to observe
    ///
    /// - Parameters:
    ///   - status: Status to observe
    ///   - handler: A callback that fires every time the status event occurs
    /// - Returns: Monitor handle that can be used to remove the observer at any time.
    @discardableResult
    func observe(_ status: MonitorStatus, handler : @escaping TapeCallback)-> String{
        
        let callback = handler
        let key = UUID.init().uuidString
        
        
        switch status {
        case .resume:
            synced(self, closure: { 
                resumeMaster.updateValue(callback, forKey: key)
            })
            break
        case .pause:
            synced(self, closure: { 
                pauseMaster.updateValue(callback, forKey: key)
            })
            break
        case .progress:
            synced(self, closure: {
                progressMaster.updateValue(callback, forKey: key)
            })
            break
        case .failure:
            synced(self, closure: {
                failureMaster.updateValue(callback, forKey: key)
            })
            break
            
        case .success:
            synced(self, closure: {
                sucessMaster.updateValue(callback, forKey: key)
            })
            break
            
        }
        
        
        masterMap.updateValue(status, forKey: key)
        return key
    }
    
    
    /// Remove a single observer
    ///
    /// - Parameter key: Observer's Monitor Handle generated from the observer function
    func removeObserver(withKey key :String){
        var dictionary = getHandler(fromMaster: key)
        
        synced(self) {
            dictionary?.removeValue(forKey: key)
            masterMap.removeValue(forKey: key)
        }
        
    }
    
    
    /// Remove all Observers of a Status
    ///
    /// - Parameter status: Status to remove all observers from
    func removeObserver(withStatus status : MonitorStatus){
        var dictionary = getHandler(fromStatus: status)
        
        synced(self) {
            dictionary.removeAll()
            masterMap.forEach({ (key, value) in
                if value == status {
                    masterMap.removeValue(forKey: key)
                }
            })
        }
        
    }
    
    
    
    /// Remove all observers from the Tape Monitor
    func removeAllObservers(){
        synced(self) {
            resumeMaster.removeAll()
            pauseMaster.removeAll()
            progressMaster.removeAll()
            failureMaster.removeAll()
            sucessMaster.removeAll()
            masterMap.removeAll()
        }
    }
    
    
    /// Get the handler container that holds the observer
    ///
    /// - Parameter key: Observer's Monitor Handle
    /// - Returns: Handler container
    private func getHandler(fromMaster key : String)-> Dictionary<String, TapeCallback>?{
        guard let status = masterMap[key] else {
            return nil
        }
        
        return getHandler(fromStatus: status)
        
    }
    
    
    /// Get the handler container for a TapeStatus
    ///
    /// - Parameter status: Status corresponsing to the container
    /// - Returns: Handler container
    private func getHandler(fromStatus status : MonitorStatus)-> Dictionary<String, TapeCallback> {
        switch status {
        case .resume:
            return resumeMaster
        case .pause:
            return pauseMaster
        case .progress:
            return progressMaster
        case .success:
            return sucessMaster
        case .failure:
            return failureMaster
        }
    }
    
    
    /// Fire Event for all observers for the provided TapeStatus
    ///
    /// - Parameters:
    ///   - status: TapeStatus to fire an event for
    ///   - value: optional Value associated with the event
    fileprivate func fire(withStatus status : MonitorStatus, value : Any? = nil){
        
        if value != nil {
            if value is Double {
                self.progress = value as! Double
            }
            if value is AudioError? {
                self.error = value as? AudioError
            }
        }
        
        self.fire(withHandler: getHandler(fromStatus: status), self.tapePiece)
        
        if status == .failure || status == .success {
            removeAllObservers()
        }
    }
    
    
    /// Fire Event for all observers within the provided Handler
    ///
    /// - Parameters:
    ///   - handler: Handler container
    ///   - tapePiece: TapePiece to pass to observers that contain the information about the current monitor session
    fileprivate func fire(withHandler handler : Dictionary<String, TapeCallback>,_ tapePiece: TapePiece){
        
        synced(self) {
            handler.forEach { (key, value) in
                DispatchQueue.main.async {
                    value(tapePiece)
                }
            }
        }
        
    }
    

    /// Helper Function to obtain objc @synchronized
    ///
    /// - Author: Source- Bryan McLemore &  devios1 - [link](https://stackoverflow.com/a/24103086/7542055)
    ///
    /// - Parameters:
    ///   - lock: Object to sync
    ///   - closure: Closure to exceute in the sync'd state
    fileprivate func synced(_ lock: Any, closure: () -> ()) {
        objc_sync_enter(lock)
        defer {
            objc_sync_exit(lock)
        }
        closure()
    }
    
}


/// Functions that a Operational Monitor must implement
public protocol OperationMonitorType: NSObjectProtocol {
    
    /// Start the monitor
    func start()
    
    /// Pause the monitor
    func pause()
    
    /// Stop the monitor with a status
    ///
    /// - Parameters:
    ///   - status: Reason why the monitor was stopped
    ///   - error: Error involed with the stopage
    func stop(_ status: AudioStatus, error : AudioError?)
    
    /// Resume the monitor
    func resume()
}



/// Manages Observation Callbacks and Operations throughout a Recording
public class RecordTapeMonitor: TapeMonitor, OperationMonitorType {

    
    /// Reference to the TapeRecorder's recorder to control it, i.e. record(),stop(),pause(),resume()
    unowned var recorder : AVAudioRecorder
    
    private weak var recording : Recording!
    
    /// Local Timer to update duration
    fileprivate var timer : Timer?
    
    init(recorder: AVAudioRecorder, _ recording: Recording) {
        self.recorder = recorder
        self.recording = recording
        super.init()
    }
    
    /// Start the monitor and the recorder
    public func start() { 
        recorder.record()
        
        super.fire(withStatus: .progress, value: 0.0)
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    
    
    /// Update the duration of the current monitor session to the tapeRecorder's duration and fire progress events
    @objc private func updateProgress() {
        let duration = recorder.currentTime
        print(String.init(format: "Recording duration: %.2f", duration))
        
        super.fire(withStatus: .progress, value: duration)
        
        if duration >= RecordingDurationMax{
            self.stop(.sucess, error: nil)
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
            super.fire(withStatus: .failure, value: error)
            deleteTempRecording()
            return
        }
        switch status {
        case .interruption: //TODO: Have some way to mark track if there was an interruption
            break
        case .sucess:
            self.recordingFinished()
        case .cancel:
            if self.progress <= RecordingDurationMin {
                super.fire(withStatus: .failure, value: AudioError.tooShort)
            }
            else {
                self.recordingFinished()
            }
        default:
            break
        }
        
    }
    
    /// Pause the monitor and the recorder
    public func pause() {
        if recorder.isRecording {
            timer?.invalidate()
            recorder.pause()
            print("Recorder Paused")
        }
        AudioKit.stop()
    }
    
    /// Resume the monitor and the recorder
    public func resume() {
        AudioKit.start()
        if recorder.isRecording {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
            recorder.record()
            print("Recorder Resumed")
        }
    }
    
    
    /// Handle the passing of the current tapeRecorder's recordings after a successful session
    private func recordingFinished(){
        fire(withHandler: sucessMaster, TapePiece(duration: self.progress, error: self.error, recording: self.recording))
    }
    
    
    
    /// Delete the current session's recording if the session ended with an Error
    private func deleteTempRecording() {
        ResourceManager.manager.deleteRecording(recording: self.recording)
    }
}
