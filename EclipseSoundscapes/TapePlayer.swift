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
    func interrupted()
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
    
    private var wasPlaying = false
    private var playing = false
    private var isFinished = false
    
    var isPlaying : Bool {
        return player.isPlaying
    }
    
    var rate : Double {
        return Double(player.rate)
    }
    
    //Audio player
    private var player : AVAudioPlayer!
    
    /// Local Timer to update duration
    fileprivate weak var timer : Timer?
    
    var progress : Double = 0.0
    
    
    
    init(tape: Tape) {
        super.init()
        self.tape = tape
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(_:)), name: NSNotification.Name.AVAudioSessionInterruption, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(systemStop), name: NSNotification.Name.AVAudioSessionMediaServicesWereLost, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(systemRestart), name: NSNotification.Name.AVAudioSessionMediaServicesWereReset, object: nil)
        try? prepareSession()
    }
    
    deinit {
        //Remove from Recieving Notification when dealloc'd
        NotificationCenter.default.removeObserver(self)
        delegate = nil
        player = nil
        timer = nil
        print("Destroyed Player")
    }
    
    func prepareSession() throws {
        do {
            try AKSettings.setSession(category: .playAndRecord, with: .defaultToSpeaker)
            if player == nil {
                player = try AVAudioPlayer(contentsOf: (tape?.audioUrl)!)
                player.delegate = self
            }
        } catch {
            throw error
        }
    }
    
    /// Stop the monitor and the player with a status
    ///
    /// - Parameters:
    ///   - status: Reason why the monitor was stopped
    public func stop(_ status: PlaybackStatus) {
        if !isFinished {
            timer?.invalidate()
            timer = nil
            switch status {
            case .finished:
                isFinished = true
                playing = false
                self.delegate?.finished()
                self.player.stop()
                try? AKSettings.session.setActive(false)
                break
            case .interrupted:
                wasPlaying = playing
                self.pause()
                break
            }
        }
    }
    
    func play() {
        if isFinished {
            try? prepareSession()
            isFinished = false
        }
        
        playing = true
        self.player.play()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    
    /// Pause the Player
    public func pause() {
        playing = false
        timer?.invalidate()
        player.pause()
    }
    
    /// Resume the Player
    public func resume() {
        if wasPlaying {
            self.play()
        }
        self.delegate?.resumed()
    }
    
    public func changeTime(to time: TimeInterval){
        self.player.currentTime = time
    }
    
    /// Update the duration of the current monitor session to the tapeRecorder's duration and fire progress events
    @objc private func updateProgress() {
        
        self.progress = player.currentTime
        self.delegate?.progress(self.progress)
    }
    
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
            self.resume()
        }
    }
    
    func systemStop() {
        self.stop(.interrupted)
    }
    
    func systemRestart() {
        do {
            try prepareSession()
            self.changeTime(to: self.progress)
            if wasPlaying {
                self.play()
            }
        } catch  {
            print("Error trying to restart the player: \(error.localizedDescription)")
        }
    }
}

extension TapePlayer : AVAudioPlayerDelegate {
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.stop(.finished)
    }
}
