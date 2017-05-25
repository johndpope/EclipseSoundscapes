//
//  Locationator.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 5/25/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import Foundation
import CoreLocation

class Locator {
    
    static let Radius = 100
    
    
    
    
    static func buildString(withLatitude latitude : CLLocationDegrees, longitude: CLLocationDegrees)-> String {
        
        let lat = latitude
        let long = longitude
        
        
        let latString = String(lat)
        let longString = String(long)
        
        var keyString : String = String()
        
        
        keyString.append(latString)
        
        keyString.append("*")
        
        keyString.append(longString)
        
        
        print(keyString)
        
        return keyString
    }
    
    func deconstruct(fromString key: String)-> CLLocationCoordinate2D?{
        
        let components = key.components(separatedBy: "*")
        
        print(components)
        
        guard let lat = CLLocationDegrees(components[0]), let long = CLLocationDegrees(components[1]) else {
            return nil
        }
        
        return CLLocationCoordinate2D(latitude: lat, longitude: long)
        
    }
    
    
    
    
    
}
