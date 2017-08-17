//
//  Media.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 8/8/17.
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

import UIKit

public class Media : NSObject {
    var name: String!
    var resourceName : String!
    var infoRecourceName : String!
    var image: UIImage?
    var mediaType : FileType?
    
    init(name: String, resourceName : String, infoRecourceName: String , mediaType: FileType? = nil, image: UIImage? = nil) {
        self.name = name
        self.resourceName = resourceName
        self.image = image
        self.mediaType = mediaType
        self.infoRecourceName = infoRecourceName
    }
    
    func getInfo() -> String {
        return Utility.getFile(infoRecourceName, type: "txt") ?? "No Info Provided"
    }
    
}

class RealtimeMedia : NSObject {
    var name: String!
    var infoRecourceName : String!
    var image: UIImage!
    var startTime : Double!
    var endTime : Double!
    
    init(name: String, infoRecourceName: String, image: UIImage, startTime: Double, endTime: Double) {
        self.name = name
        self.image = image
        self.infoRecourceName = infoRecourceName
        self.startTime = startTime
        self.endTime = endTime
    }
    
}
public class RealtimeEvent: Media {
    
    let END = -3
    let INTERMISSION = -2
    private var index = -1
    
    var mediaInterval : [Double]!
    
    private var names: [String]!
    private var images : [UIImage]?
    private var infoResourceNames : [String]!
    
    private var media : [RealtimeMedia]!
    
    
    init(name: String, resourceName: String, mediaType: FileType, image: UIImage, media : RealtimeMedia...) {
        super.init(name: name, resourceName: resourceName, infoRecourceName: media[0].infoRecourceName, mediaType: mediaType, image: image)
        self.media = media
    }
    
    func shouldChangeMedia(for time: Double) -> Bool {
        
        let index = getIndex(for: time)
        
        switch index {
        case END:
            return true
        case INTERMISSION:
            return true
        default:
            return self.index != index
        }
    }
    
    private func getIndex(for time: Double) -> Int{
        if self.media[media.count-1].endTime == time {
            return END
        }
        
        for i in 0 ..< media.count {
            let media = self.media[i]
            
            if time >= media.startTime && time < media.endTime {
                return i
            }
            
        }
        return INTERMISSION
    }
    
    private func getNextMedia(after time: Double) -> RealtimeMedia {
        var targetMedia : RealtimeMedia!
        for i in 0 ..< media.count {
            let tempMedia = self.media[i]
            if time < tempMedia.endTime {
                targetMedia =  tempMedia
                break
            }
        }
        if targetMedia == nil {
            targetMedia = media[media.count-1]
        }
        
        return targetMedia
    }
    
    func loadNextMedia(for time : Double) {
        
        let index = getIndex(for: time)
        
        switch index {
        case END :
            self.name = "All Done!"
            self.infoRecourceName = "ThankYou"
            self.image = #imageLiteral(resourceName: "EclipseSoundscapes-Eclipse")
            break
        case INTERMISSION:
            self.name = "\(getNextMedia(after: time).name!) Up Next"
            self.infoRecourceName = "Intermission"
            self.image = #imageLiteral(resourceName: "EclipseSoundscapes-Eclipse")
            break
        default:
            self.index = index
            let media = self.media[self.index]
            self.name = media.name
            self.infoRecourceName = media.infoRecourceName
            self.image = media.image
        }
        
    }
    
}
