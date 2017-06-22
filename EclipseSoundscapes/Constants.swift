//
//  AudioConstants.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 6/7/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import Foundation
import UIKit

/// Status of the Tape during a Monitor Session
///
/// - progress: Monitor progress event
/// - success: Tape has completed successfully
/// - failure: Tape has completed due to an error
/// - pause: Tape was paused
/// - resume: Tape was resumed
/// - skip: Tape was skipped
public enum MonitorStatus {
    case progress
    case success
    case failure
    case pause
    case resume
}

/// Status of Audio operation
///
/// - sucess: Successful audio operation
/// - error: Error occured while performing operation
/// - interruption: Interruption occured while performing operation
/// - cancel: Audio operation was cancelled
public enum AudioStatus {
    case success
    case error
    case interruption
    case cancel
}

/// Status of Playback operation
///
/// - finished: Sucessful audio playback
/// - cancel: Playback was cancelled
/// - skip: Plyabck was skipped
public enum PlaybackStatus {
    case finished, cancel, skip
}

/// Error involved during an Audio operation
///
/// - tooShort: Audio Recoring was too short
/// - micPermissionDenied: Permission to Record from internal mic was denied
/// - system: System generated Error
/// - unown: Unkown Error
public enum AudioError: Error {
    case tooShort
    case micPermissionDenied
    case locationPermissionError
    case system(Error)
    case unkown
    case noTapeSet
    case playbackEnded
    case skipped
    case needMoreTapes
}

/// Upload/Download Status keys
public enum NetworkStatus {
    case audioSuccess
    case jsonSuccess
    case realtimeSuccess
    case error(Error)
    case cancelled
    case paused
}

/// Key for CitizenScientists Directory in Firebase
let CitizenScientistsDirectory = "CitizenScientists"

/// Key for GeoFire data in Firebase RealtimeDB
let LocationDirectory = "Locations"

//let AllRecordings = "Recordings"

/// Audio File Type
let FileType = ".m4a"

/// 5 minute maximum
let RecordingDurationMax :Double = 300

/// 20 second minimum
let RecordingDurationMin :Double = 20
