//
//  Tape.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 5/26/17.
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
import CoreLocation

/// Audio Recording that has been downloaded from Firebase
public class Tape : NSObject {
    
    /// Location where the Recording was performed
    var location : CLLocationCoordinate2D?
    
    /// User Set Title of the Recording
    var title : String?
    
    /// Duration of the Recording
    var duration : Double?
    
    /// Unique ID of the Recording
    var id : String?
    
    /// URL to the location where the Recording is saved locally
    var audioUrl : URL?
    
    init(withAudio audioUrl : URL) {
        super.init()
        
        self.audioUrl = audioUrl
        
    }
    
    init(withInfo info : Dictionary<String, Any>, _ audioUrl : URL? = nil) {
        super.init()
        setInformation(info: info)
        
        if audioUrl != nil {
            self.audioUrl = audioUrl!
        }
        
    }
    
    /// Set the Information of the recording
    ///
    /// - Parameter info: Key-value pairs containg the inforamtion about the REcording
    func setInformation(info : Dictionary<String, Any>) {
        if let id  = info[Recording.ID] as? String {
            self.id = id
        }
        
        if let title = info[Recording.TITLE] as? String {
            self.title = title
        }
        
        if let duration = info[Recording.DURATION] as? Double {
            self.duration = duration
        }
        
        if let latitude = info[Recording.LAT] as? Double, let longitude = info[Recording.LONG] as? Double {
            self.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    /// Set the location where the Recording is saved locally
    ///
    /// - Parameter audioUrl: URL to downloaded audio file
    func setAudioUrl(audioUrl : URL) {
        self.audioUrl = audioUrl
    }
    
}
