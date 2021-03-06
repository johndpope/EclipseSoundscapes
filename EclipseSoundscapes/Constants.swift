//
//  Constants.swift
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

/// Status of Playback operation
///
/// - finished: Audio playback completed
/// - skip: Plyabck was skipped
public enum PlaybackStatus {
    case finished, interrupted, resumed, progress
}

/// File Types
///
/// - m4a: m4a audio file
/// - mp3: mp3 audio file
/// - wav: wav audio file
enum FileType : String {
    case m4a = "m4a"
    case mp3 = "mp3"
    case wav = "wav"
}

/// Futura Font Family
enum Futura {
    case condensedMedium
    case extraBold
    case meduium
    case italic
    case bold
}


/// Position of the screen
///
/// - top: Top of screen
/// - bottom: Bottom on screen
enum ScreenPosition {
    case top, bottom
}
