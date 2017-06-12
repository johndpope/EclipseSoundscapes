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
import Synchronized

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
    func observe(_ status : MonitorStatus, handler : @escaping TapeCallback) -> String {
        
        let callback = handler
        let key = UUID.init().uuidString
        
        var dictionary = getHandler(fromStatus: status)
        
        synchronized(object: self) { 
            dictionary.updateValue(callback, forKey: key)
            masterMap.updateValue(status, forKey: key)
        }
        
        return key
    }
    
    /// Remove a single observer
    ///
    /// - Parameter key: Observer's Monitor Handle generated from the observer function
    func removeObserver(withKey key : String) {
        var dictionary = getHandler(fromMaster: key)
        
        synchronized(object: self) {
            dictionary?.removeValue(forKey: key)
            masterMap.removeValue(forKey: key)
        }
        
    }
    
    /// Remove all Observers of a Status
    ///
    /// - Parameter status: Status to remove all observers from
    func removeObserver(withStatus status : MonitorStatus) {
        var dictionary = getHandler(fromStatus: status)
        
        synchronized(object: self) { 
            dictionary.removeAll()
            masterMap.forEach({ (key, value) in
                if value == status {
                    masterMap.removeValue(forKey: key)
                }
            })
        }
    }
    
    /// Remove all observers from the Tape Monitor
    func removeAllObservers() {
        synchronized(object: self) { 
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
    private func getHandler(fromMaster key : String) -> Dictionary<String, TapeCallback>? {
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
    fileprivate func fire(withStatus status : MonitorStatus, value : Any? = nil) {
        
        if value != nil {
            if value is Double {
                self.progress = value as! Double
            }
            if value is AudioError? {
                self.error = value as? AudioError
            }
        }
        
        self.fire(withHandler: getHandler(fromStatus: status), self.tapePiece)
    }
    
    /// Fire Event for all observers within the provided Handler
    ///
    /// - Parameters:
    ///   - handler: Handler container
    ///   - tapePiece: TapePiece to pass to observers that contain the information about the current monitor session
    fileprivate func fire(withHandler handler : Dictionary<String, TapeCallback>, _ tapePiece: TapePiece) {
        
        synchronized(object: self) { 
            handler.forEach({ (_, value) in
                DispatchQueue.main.async {
                    value(tapePiece)
                }
            })
        }
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

/// Manages Observation Callbacks and Operations throughout a Playback
public class TapePlaybackSession: TapeMonitor, OperationMonitorType {
    
    enum PlayerState {
        case stoped, playing, paused
    }

    var state : PlayerState = PlayerState.stoped
    
    //Audio Player
    unowned var player : AKAudioPlayer
    
    /// Local Timer to update duration
    fileprivate var timer : Timer?
    
    init(player : AKAudioPlayer) {
        self.player = player
        super.init()
        player.completionHandler = self.playingEnded
        
    }
    
    /// Start the Player
    public func start() {
        player.play()
        
        state = .playing
        super.fire(withStatus: .progress, value: 0.0)
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    
    /// Update the duration of the current monitor session to the tapeRecorder's duration and fire progress events
    @objc private func updateProgress() {
        
        let progress = player.currentTime
        print(String.init(format: "Player progress: %.2f", progress))
        
        super.fire(withStatus: .progress, value: progress)
    }
    
    /// Stop the monitor and the player with a status
    ///
    /// - Parameters:
    ///   - status: Reason why the monitor was stopped
    ///   - error: Error involed with the stopage
    public func stop(_ status: AudioStatus, error: AudioError? = nil) {
        
        stopMonitor()
        guard error == nil else {
            super.fire(withStatus: .failure, value: error)
            return
        }
        switch status {
        case .success: //TODO: Tape has ended
            super.fire(withStatus: .success)
            break
        case .cancel: //TODO: Audio Playback was ended
            super.fire(withStatus: .failure, value: AudioError.playbackEnded)
            break
        default:
            break
        }
        deleteDownloadedTape()
    }
    
    /// Pause the Player
    public func pause() {
        if timer?.isValid ?? true {
            timer?.invalidate()
        }
        if player.isPlaying {
            player.pause()
        }
        state = .paused
        super.fire(withStatus: .pause)
        AudioKit.stop()
    }
    
    /// Resume the Player
    public func resume() {
        AudioKit.start()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        if player.isStopped {
            player.resume()
        }
        state = .playing
        super.fire(withStatus: .resume)
    }
    
    func switchTape(tape: Tape) throws {
        super.fire(withStatus: .failure, value: AudioError.skipped)
        if self.state != .stoped {
            stopMonitor()
        }
        do {
            let file = try AudioManager.makeAudiofile(url: tape.audioUrl)
            try self.player.replace(file: file)
            self.start()
        } catch {
            throw error
        }
    }
    
    private func playingEnded() {
        if state == .stoped {
            return
        }
        self.stopMonitor()
        self.stop(.success)
    }
    
    private func stopMonitor() {
        state = .stoped
        timer?.invalidate()
        if player.isPlaying {
            player.stop()
        }
        AudioKit.stop()
    }
    
    private func deleteDownloadedTape() {
        AKAudioFile.cleanTempDirectory()
    }

}
