//
//  TapePlayer.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 6/7/17.
//
//  Copyright © 2017 Arlindo Goncalves.
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see [http://www.gnu.org/licenses/].
//
//  For Contact email: arlindo@eclipsesoundscapes.org

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
    
    var duration : TimeInterval {
        return player.duration
    }
    
    //Audio player
    var player : AVAudioPlayer!
    
    /// Local Timer to update duration
    fileprivate weak var timer : Timer?
    
    var progress : Double = 0.0
    
    init(tape: Tape) {
        super.init()
        self.tape = tape
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(_:)), name: NSNotification.Name.AVAudioSessionInterruption, object: nil)
        try? prepareSession()
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
            player.delegate = self
        } catch {
            throw error
        }
    }
    
    func play() {
        self.player.play()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    
    /// Stop the monitor and the player with a status
    ///
    /// - Parameters:
    ///   - status: Reason why the monitor was stopped
    public func stop(_ status: PlaybackStatus) {
        timer?.invalidate()
        timer = nil
        switch status {
        case .finished: //TODO: Tape has ended
            self.delegate?.finished()
            self.player.stop()
            try? AKSettings.session.setActive(false)
            break
        case .cancel: //TODO: Audio Playback was ended by user
            break
        case .interrupted:
            self.pause()
            break
        }
    }
    
    /// Pause the Player
    public func pause() {
        timer?.invalidate()
        player.pause()
        self.delegate?.paused()
    }
    
    /// Resume the Player
    ///
    /// - Parameter flag: Flag to resume the current Audio session
    public func resume(startSesstion flag : Bool = true) {
        if flag {
            try? AKSettings.session.setActive(true)
        }
        self.play()
        self.delegate?.resumed()
    }
    
    public func changeTime(to time: TimeInterval){
        self.player.currentTime = time
    }
    
    /// Update the duration of the current monitor session to the tapeRecorder's duration and fire progress events
    @objc private func updateProgress() {
        
        self.progress = player.currentTime
        print(String.init(format: "Player progress: %.2f", progress))
        self.delegate?.progress(self.progress)
    }
}

extension TapePlayer : AVAudioPlayerDelegate {
    /// Interruption Handler
    ///
    /// - Parameter notification: Device generated notification about interruption
    @objc fileprivate func handleInterruption(_ notification: Notification) {
        let theInterruptionType = (notification as NSNotification).userInfo![AVAudioSessionInterruptionTypeKey] as! UInt
        NSLog("Session interrupted > --- %@ ---\n", theInterruptionType == AVAudioSessionInterruptionType.began.rawValue ? "Begin Interruption" : "End Interruption")
        
        if theInterruptionType == AVAudioSessionInterruptionType.began.rawValue {
            //Interruption Started
            self.stop(.interrupted)
        }
        
        if theInterruptionType == AVAudioSessionInterruptionType.ended.rawValue {
            //Interruption Ended
            self.resume(startSesstion: false)
        }
    }
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.stop(.finished)
    }
}
