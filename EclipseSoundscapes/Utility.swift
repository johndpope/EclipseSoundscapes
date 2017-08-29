//
//  Utility.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 6/6/17.
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
import Material

class Utility {
    
    
    /// Delays given time before closure is excecuted
    ///
    /// - Parameters:
    ///   - delay: Time to delay closure
    ///   - closure: Action block
    static func delay(_ delay:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when) {
            closure()
        }
    }

    
    /// Opens Application Settings
    static func settings() {
        let application = UIApplication.shared
        if let url = URL(string: UIApplicationOpenSettingsURLString) {
            application.openURL(url)
        }
    }
    
    /// Convert TimeInterval into a pretty string
    ///
    /// - Parameter time: TimeInterval
    /// - Returns: Pretty Time String
    static func timeString(time:TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = time - Double(minutes) * 60
        return String(format:"%2i:%02i", minutes, Int(seconds))
    }
    
    /// Convert TimeInterval into a pretty string
    ///
    /// - Parameter time: TimeInterval
    /// - Returns: Pretty Time String
    static func timeAccessibilityString(time:TimeInterval) -> String {
        
        let minutes = Int(time) / 60
        let multipleMinutes = minutes != 1
        
        let seconds = time - Double(minutes) * 60
        let multipleSeconds = seconds != 1
        
        if minutes == 0 {
            return String(format:"%i %@", Int(seconds), multipleSeconds ? "seconds" : "second")
        } else if seconds == 0 {
            return "0"
        } else {
    
        return String(format:"%i %@ %i %@", minutes, multipleMinutes ? "minutes" : "minute", Int(seconds), multipleSeconds ? "seconds" : "second")
        }
    }
    
    static func getFile(_ filename: String, type : String) -> String? {
        if let path = Bundle.main.path(forResource: filename, ofType: type) {
            do {
                let text = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                return text
            } catch {
                print("Failed to read text from \(filename)")
            }
        } else {
            print("Failed to load file from app bundle \(filename)")
        }
        return nil
    }
    
    /// Gets the Top-most ViewController
    static func getTopViewController() -> UIViewController {
        
        var viewController = UIViewController()
        
        if let vc =  UIApplication.shared.delegate?.window??.rootViewController {
            
            viewController = vc
            var presented = vc
            
            while let top = presented.presentedViewController {
                presented = top
                viewController = top
            }
        }
        
        return viewController
    }
    
    
    /// Get Local Time from UTC
    ///
    /// - Parameter date: UTC Date String
    /// - Returns: Local Time Date String 
    static func UTCToLocal(date:String) -> String {
        let dateFormator = DateFormatter()
        dateFormator.dateFormat = "HH:mm:ss.S"
        dateFormator.timeZone = TimeZone(abbreviation: "UTC")
        
        guard let conversionDate = dateFormator.date(from: date) else {
            return "Not Available"
        }
        
        dateFormator.timeZone = .current
        dateFormator.dateFormat = "h:mm:ss a"
        
        if TimeZone.autoupdatingCurrent.isDaylightSavingTime() {
            return dateFormator.string(from: conversionDate.addingTimeInterval(TimeZone.current.daylightSavingTimeOffset()))
        } else {
            return dateFormator.string(from: conversionDate)
        }
    }
    
}

extension Color {
    static let eclipseOrange = UIColor.init(r: 227, g: 94, b: 5)
    static let lead = UIColor.init(r: 33, g: 33, b: 33)
}
