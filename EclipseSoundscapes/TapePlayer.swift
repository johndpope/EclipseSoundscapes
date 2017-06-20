//
//  TapePlayer.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 6/7/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import Foundation
import AudioKit

protocol PlayerDelegate : NSObjectProtocol {
    func progress(_ progress: Double)
    func finished()
    func paused()
    func resumed()
}

/// Handles operations for Audio Playback
public class TapePlayer : NSObject {
    
    weak var delegate : PlayerDelegate?
    
    /// Tape to play audio from
    weak var tape: Tape?
    
    //Audio player
    var player : AVAudioPlayer!
    
    /// Local Timer to update duration
    fileprivate weak var timer : Timer?
    
    var progress : Double = 0.0
    
    init(tape: Tape) {
        super.init()
        self.tape = tape
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(_:)), name: NSNotification.Name.AVAudioSessionInterruption, object: nil)
    }
    
    deinit {
        //Remove from Recieving Notification when dealloc'd
        NotificationCenter.default.removeObserver(self)
        player = nil
        timer = nil
        print("Destroyed Player")
    }
    
    func prepareSession() throws {
        do {
            try AKSettings.setSession(category: .playAndRecord, with: .defaultToSpeaker)
            try AKSettings.session.setActive(true)
            player  = try AVAudioPlayer(contentsOf: (tape?.audioUrl)!)

        } catch {
            throw error
        }
    }
    
    func play() throws {
        do {
            try prepareSession()
            self.player.play()
            self.delegate?.progress(self.progress)
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        } catch {
            throw error
        }
    }
    
    /// Stop the monitor and the player with a status
    ///
    /// - Parameters:
    ///   - status: Reason why the monitor was stopped
    public func stop(_ status: PlaybackStatus) {
        if timer?.isValid ?? true {
            timer?.invalidate()
        }
        self.player.stop()
        try? AKSettings.session.setActive(false)
        deleteDownloadedTape()
        switch status {
        case .finished: //TODO: Tape has ended
            self.delegate?.finished()
            break
        case .cancel: //TODO: Audio Playback was ended
            break
        case .skip: //TODO: Handle Skip
            break
        }
    }
    
    /// Pause the Player
    ///
    /// - Parameter flag: Flag to pause the current Audio Session
    public func pause(stopSession flag : Bool = true) {
        if timer?.isValid ?? true {
            timer?.invalidate()
        }
        if player.isPlaying {
            player.pause()
        }
        self.delegate?.paused()
        
        if flag {
            try? AKSettings.session.setActive(false)
        }
    }
    
    /// Resume the Player
    ///
    /// - Parameter flag: Flag to resume the current Audio session
    public func resume(startSesstion flag : Bool = true) {
        
        if flag {
            try? AKSettings.session.setActive(true)
        }
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        if !player.isPlaying {
            player.play()
        }
        self.delegate?.resumed()
    }
    
    /// Update the duration of the current monitor session to the tapeRecorder's duration and fire progress events
    @objc private func updateProgress() {
        
        self.progress = player.currentTime
        print(String.init(format: "Player progress: %.2f", progress))
        self.delegate?.progress(self.progress)
        
        if !player.isPlaying {
            self.stop(.finished)
        }
    }
    
    private func deleteDownloadedTape() {
        ResourceManager.deleteFile(atPath: self.player.url)
    }
    
}

extension TapePlayer {
    /// Interruption Handler
    ///
    /// - Parameter notification: Device generated notification about interruption
    @objc fileprivate func handleInterruption(_ notification: Notification) {
        let theInterruptionType = (notification as NSNotification).userInfo![AVAudioSessionInterruptionTypeKey] as! UInt
        NSLog("Session interrupted > --- %@ ---\n", theInterruptionType == AVAudioSessionInterruptionType.began.rawValue ? "Begin Interruption" : "End Interruption")
        
        if theInterruptionType == AVAudioSessionInterruptionType.began.rawValue {
            //Interruption Started
            self.pause(stopSession: false)
        }
        
        if theInterruptionType == AVAudioSessionInterruptionType.ended.rawValue {
            //Interruption Ended
            self.resume(startSesstion: false)
        }
    }
}
