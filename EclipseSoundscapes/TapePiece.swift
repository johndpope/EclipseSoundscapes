//
//  TapePiece.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 5/31/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import Foundation


/// Contains the inforamtion about the Current TapeMonitor Session
public class TapePiece {
    
    /// Progress of the session
    private var _progress : Double = 0
    
    /// Error during the session
    var error : AudioError?
    
    /// Recording after a successful session
    var recording : Recording?
    
    
    //Access to immuatable session progress
    var progress : Double {
        return _progress
    }
    
    init(duration: Double, error: AudioError? = nil, recording: Recording? = nil) {
        self._progress = duration
        self.error = error
        self.recording = recording
    }
}
