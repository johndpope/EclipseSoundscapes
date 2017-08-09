//
//  AudioConstants.swift
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
    case finished, cancel, interrupted
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
enum FileType : String {
    case m4a = "m4a"
    case mp3 = "mp3"
    case wav = "wav"
}

/// 5 minute maximum
let RecordingDurationMax :Double = 300

/// 20 second minimum
let RecordingDurationMin :Double = 20
