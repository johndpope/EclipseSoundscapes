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

import AVFoundation

enum TapeError : Error {
    case resourceNotFound
}

/// Tape Player Delegate
protocol PlayerDelegate : NSObjectProtocol {
    
    /// Update Progress
    ///
    /// - Parameter progress: Current Tape's progress
    func progress(_ progress: Double)
    
    /// Notify Player Finished
    func finished()
    
    /// Notify Player Interrupted
    func interrupted()
    
    /// Notify Player Resumed
    func resumed()
}

/// Handles operations for Audio Playback
public class TapePlayer : NSObject {
    
   weak var delegate : PlayerDelegate?
    
    /// Tape to play audio from
    var tape: Tape?
    
    
    /// Total duration of the player
    var duration : TimeInterval {
        return player?.duration ?? 0
    }
    
    /// Returns if the player is currently playing
    var isPlaying : Bool {
        return player?.isPlaying ?? false
    }
    
    //MARK: Private Variables
    
    /// Local Audio Session
    private var session = AVAudioSession.sharedInstance()
    
    /// Local was playing
    private var wasPlaying = false
    
    /// Local isPlaying
    private var playing = false
    
    /// Local isFinished
    private var isFinished = false
    
    /// Checks if headphones were plugged
    private var headPhonesPlugged: Bool!
    
    //Audio player
    private var player : AVAudioPlayer?
    
    /// Local Timer to update duration
    fileprivate weak var timer : Timer?
    
    /// Current Playing Time
    var progress : Double = 0.0
    
    init(tape: Tape) throws {
        super.init()
        self.tape = tape
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(_:)), name: NSNotification.Name.AVAudioSessionInterruption, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(systemRestart), name: NSNotification.Name.AVAudioSessionMediaServicesWereReset, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceConnectedNotification), name: Notification.Name.AVAudioSessionRouteChange, object: nil)
        
        NotificationCenter.default.addObserver(forName: .AVAudioSessionRouteChange, object: nil, queue: OperationQueue.main, using: deviceConnectedNotification(notification:))
        
        do {
            try prepareSession()
        } catch  {
            throw error
        }
    }
    
    deinit {
        //Remove from Recieving Notification when dealloc'd
        NotificationCenter.default.removeObserver(self)
        delegate = nil
        player = nil
        timer = nil
        print("Destroyed Player")
    }
    
    
    /// Load resource into Tape Player
    ///
    /// - Parameters:
    ///   - name: Name of resource
    ///   - ext: Resource tyoe
    /// - Returns: Tape Player
    /// - Throws: Error involved with trying to load media such as resource not in bundle or error in starting the Audio Session
    class func loadTape(withName name: String, withExtension ext: FileType?) throws -> TapePlayer {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext?.rawValue) else {
            throw TapeError.resourceNotFound
        }
        
        let tape = Tape(audioUrl: url)
        do {
            let player = try TapePlayer(tape: tape)
            return player
        } catch {
            throw error
        }
    }
    
    /// Prepares the Audio Session and player
    ///
    /// - Throws: Error in preparing session
    func prepareSession() throws {
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            try session.setActive(true)
            
            headPhonesPlugged = session.currentRoute.outputs.contains {
                $0.portType == AVAudioSessionPortHeadphones
            }
            if let url = tape?.audioUrl {
                player = try AVAudioPlayer(contentsOf: url)
                player?.delegate = self
            }
        } catch {
            throw error
        }
    }
    
    /// Stop the player
    public func stop() {
        if !isFinished {
            timer?.invalidate()
            timer = nil
            isFinished = true
            playing = false
            self.delegate?.finished()
            self.player?.stop()
            self.player = nil
            try? session.setActive(false)
        }
    }
    
    
    /// Play audio
    func play() {
        if isFinished {
            try? prepareSession()
            isFinished = false
        }
        
        playing = true
        self.player?.play()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    
    /// Pause the Player
    public func pause() {
        playing = false
        timer?.invalidate()
        player?.pause()
    }
    
    /// Resume the Player
    private func resume() {
        if wasPlaying {
            self.play()
        }
        self.post(.resumed)
    }
    
    /// Interruption Occured while the Player was non-nil
    private func interrupt() {
        self.post(.interrupted)
        wasPlaying = playing
        self.pause()
    }
    
    
    /// Seek Audio forward or backwards
    ///
    /// - Parameter time: Time to seek audio to
    public func changeTime(to time: TimeInterval){
        self.player?.currentTime = time
    }
    
    /// Update the duration of the current monitor session to the tapeRecorder's duration and fire progress events
    @objc private func updateProgress() {
        guard let currentTime = player?.currentTime else {
            return
        }
        
        self.progress = currentTime
        self.delegate?.progress(self.progress)
    }
    
    /// Interruption Handler
    ///
    /// - Parameter notification: Device generated notification about interruption
    @objc private func handleInterruption(_ notification: Notification) {
        guard let info = notification.userInfo,
            let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSessionInterruptionType(rawValue: typeValue) else {
                return
        }
        if type == .began {
            // Interruption began, take appropriate actions (save state, update user interface)
            self.interrupt()
            
        }
        else if type == .ended {
            guard let optionsValue =
                info[AVAudioSessionInterruptionOptionKey] as? UInt else {
                    return
            }
            let options = AVAudioSessionInterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                // Interruption Ended - playback should resume
                self.resume()
            }
        }
        
        
    }
    
    
    /// Notification handler for AVAudioSessionRouteChange to catch changes to device connection from the audio jack.
    ///
    /// - Parameter notification: Notification object cointaing AVAudioSessionRouteChange data
    @objc private func deviceConnectedNotification(notification: Notification){
        guard let info = notification.userInfo,
            let typeValue = info[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let type = AVAudioSessionRouteChangeReason(rawValue: typeValue) else {
                return
        }
        switch type {
        case AVAudioSessionRouteChangeReason.newDeviceAvailable: ///device is connected
            headPhonesPlugged = true
            self.resume()
            break
            
        case AVAudioSessionRouteChangeReason.oldDeviceUnavailable: ///device is not connected
            if headPhonesPlugged {
                self.interrupt()
            }
            headPhonesPlugged = false
            break
        default:
            break
        }
    }
    
    
    /// Callback for AVAudioSessionMediaServicesWereReset notification
    func systemRestart() {
        self.interrupt()
        if let url = tape?.audioUrl {
            do {
                try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
                player = try AVAudioPlayer(contentsOf: url)
                player?.delegate = self
                player?.currentTime = self.progress
            } catch  {
                print("Problem Reinit for Player During System Restart\nError: \(error.localizedDescription)")
            }
            
        }
    }
    
    
    /// Posting to the delegates all on the Main Thread
    ///
    /// - Parameters:
    ///   - status: Current Playback Status
    ///   - object: Optional object to pass to delegate
    private func post(_ status : PlaybackStatus, _ object: Any? = nil){
        DispatchQueue.main.async {
            switch status {
            case .finished:
                self.delegate?.finished()
                break
            case .interrupted :
                self.delegate?.interrupted()
                break
            case .resumed :
                self.delegate?.resumed()
                break
            case .progress :
                self.delegate?.progress(object as! Double)
                break
                
            }
        }
        
    }
}

extension TapePlayer : AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.stop()
    }
}
