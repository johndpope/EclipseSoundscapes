//
//  TapePlayer.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 6/7/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import Foundation
import AudioKit


/// Handles operations for Audio Playback
public class TapePlayer : NSObject {
    
    /// Tape to play audio from
    weak var tape: Tape!
    
    //Audio player
    var player : AKAudioPlayer!
    
    /// Monitor for recording operation
    private var monitor : PlayerTapeMonitor?
    
    
    init(tape: Tape){
        super.init()
        self.tape = tape
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(_:)), name: NSNotification.Name.AVAudioSessionInterruption, object: nil)
    }
    
    deinit {
        //Remove from Recieving Notification when dealloc'd
        NotificationCenter.default.removeObserver(self)
        
        monitor = nil
        player = nil
    }
    
    func prepareRecording() throws -> PlayerTapeMonitor {
        do {
            try AKSettings.setSession(category: .playAndRecord, with: .allowBluetoothA2DP)
            
            guard let tapeUrl = tape.audioUrl else {
                throw AudioError.unkown // Throw Error for not having the tape download url
            }
            let audioFile = try AKAudioFile(forReading: tapeUrl)
        
            self.player = try AKAudioPlayer(file: audioFile)
            self.monitor = PlayerTapeMonitor(player: player)
            
            AudioKit.output = self.player
            AudioKit.start()
            
        } catch {
            throw error
        }
        
        return self.monitor!
    }
    
    
    func switchTape(tape: Tape) throws ->PlayerTapeMonitor{
        if self.monitor?.state == PlayerTapeMonitor.PlayerState.playing {
            self.monitor?.stop(.skip)
        }
        
        self.tape = tape
        
        do {
            let monitor = try prepareRecording()
            return monitor
        }
        catch{
            throw error
        }
        
    }
    
    /// Interruption Handler
    ///
    /// - Parameter notification: Device generated notification about interruption
    @objc fileprivate func handleInterruption(_ notification: Notification) {
        let theInterruptionType = (notification as NSNotification).userInfo![AVAudioSessionInterruptionTypeKey] as! UInt
        NSLog("Session interrupted > --- %@ ---\n", theInterruptionType == AVAudioSessionInterruptionType.began.rawValue ? "Begin Interruption" : "End Interruption")
        
        if theInterruptionType == AVAudioSessionInterruptionType.began.rawValue {
            //Interruption Started
            self.monitor?.pause()
        }
        
        if theInterruptionType == AVAudioSessionInterruptionType.ended.rawValue {
            //Interruption Ended
            self.monitor?.resume()
        }
    }
}
