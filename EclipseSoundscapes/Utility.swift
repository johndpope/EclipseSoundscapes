//
//  Utility.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 6/6/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import UIKit

class Utility {
    
    /// Convert TimeInterval into a pretty string
    ///
    /// - Parameter time: TimeInterval
    /// - Returns: Pretty Time String
    static func timeString(time:TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = time - Double(minutes) * 60
        return String(format:"%02i:%02i", minutes, Int(seconds))
    }
}

extension UIAlertController {
    class func appSettingsAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL.init(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(URL.init(string: UIApplicationOpenSettingsURLString)!)
            }
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alert
    }
}

public enum RadiusSize {
    case ten
    case fifty
    case hundred
    case twohundred
    case fivehundred
    case custom(Double)
}

public class SearchRadius {
    
    class func radius(withSize size: RadiusSize) -> Double {
        var temp : Double
        switch size {
        case .ten:
            temp = 10
        case .fifty:
            temp = 50
            break
        case .hundred:
            temp = 100
            break
        case .twohundred:
            temp = 200
            break
        case .fivehundred:
            temp = 500
            break
        case .custom(let input):
            temp = input
        }
        return temp * 1.60934 //Convert Miles to km for Geofire query
    }
    
    /// Increase GeoFire query radius
    /// -Important: Geofire radius is in km
    ///
    /// - Returns: New SearchRasius
    class func increase(radius: Double ) -> Double {
        let miles = radius / 1.60934
        return (miles + 10) * 1.60934
    }
}
