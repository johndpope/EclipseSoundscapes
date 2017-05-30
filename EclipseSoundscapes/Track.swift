//
//  Track.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 5/26/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import Foundation
import CoreLocation


class Track : NSObject {
    
    var location : CLLocationCoordinate2D?
    var size : Int64?
    var title : String?
    var duration : Double?
    var id : String?
    
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
    
    func setInformation(info : Dictionary<String, Any>){
        
        if let size = info[Recording.SIZE] as? Int64 {
            self.size = size
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
    
    func setAudioUrl(audioUrl : URL) {
        self.audioUrl = audioUrl
    }
    
}
