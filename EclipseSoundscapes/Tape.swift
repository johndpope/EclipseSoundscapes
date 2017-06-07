//
//  Tape.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 5/26/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import Foundation
import CoreLocation


/// Audio Recording that has been downloaded from Firebase
class Tape : NSObject {
    
    
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
    
    init(withInfo info : Dictionary<String, Any>,_ audioUrl : URL? = nil) {
        super.init()
        setInformation(info: info)
        
        if audioUrl != nil {
            self.audioUrl = audioUrl!
        }
        
    }
    
    
    /// Set the Information of the recording
    ///
    /// - Parameter info: Key-value pairs containg the inforamtion about the REcording
    func setInformation(info : Dictionary<String, Any>){
        
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
