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
    func progress(_ progress: Double, )
    func failed(withError error : AudioError)
    func finished()
    func paused()
    func resumed()
}

/// Handles operations for Audio Playback
public class TapePlayer : NSObject {
    
    /// Tape to play audio from
    weak var tape: Tape?
    
    //Audio player
    var player : AKAudioPlayer!
    
    /// Monitor for recording operation
    private var monitor : TapePlaybackSession?
    
    convenience init(tape: Tape) {
        self.init()
        self.tape = tape
    }
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(_:)), name: NSNotification.Name.AVAudioSessionInterruption, object: nil)
    }
    
    deinit {
        //Remove from Recieving Notification when dealloc'd
        NotificationCenter.default.removeObserver(self)
        
        monitor = nil
        player = nil
    }
    
    func setTape(tape: Tape) {
        self.tape = tape 
    }
    
    func play() throws {
        do {
            try prepareSession()
            self.player.play()
        } catch {
            throw error
        }
    }
    
    func prepareSession() throws {
        do {
            if #available(iOS 10.0, *) {
                try AKSettings.setSession(category: .playAndRecord, with: .allowBluetoothA2DP)
            } else {
                // Fallback on earlier versions
                try AKSettings.setSession(category: .playAndRecord, with: .allowBluetooth)
            }
            
            let file  = try AudioManager.makeAudiofile(url: tape?.audioUrl)
        
            self.player = try AKAudioPlayer(file: file)
            self.monitor = TapePlaybackSession(player: player)
            
            AudioKit.output = self.player
            AudioKit.start()
            
        } catch {
            throw error
        }
        
        return self.monitor!
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
            self.monitor?.pause()
        }
        
        if theInterruptionType == AVAudioSessionInterruptionType.ended.rawValue {
            //Interruption Ended
            self.monitor?.resume()
        }
    }
}
