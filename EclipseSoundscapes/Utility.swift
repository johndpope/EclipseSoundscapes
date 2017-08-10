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
import BRYXBanner

class Utility {
    
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
        
        let dt = dateFormator.date(from: date)
        dateFormator.timeZone = .autoupdatingCurrent
        dateFormator.dateFormat = "h:mm:ss a"
        
        if TimeZone.autoupdatingCurrent.isDaylightSavingTime() {
            return dateFormator.string(from: dt!.addingTimeInterval(TimeZone.autoupdatingCurrent.daylightSavingTimeOffset()))
        } else {
            return dateFormator.string(from: dt!)
        }
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

class Color {
    static let eclipseOrange = UIColor.init(r: 227, g: 94, b: 5)
}

extension UIView {
    
    /// Get Rombus Pattern View
    ///
    /// - Returns: Rombus Pattern View
    class func rombusPattern() -> UIView {
        let patternView = SPRequestPermissionData.views.patternView()
        let gradientView = SPGradientWithPictureView.init()
        gradientView.startColor = SPRequestPermissionData.colors.gradient.dark.lightColor()
        gradientView.endColor = SPRequestPermissionData.colors.gradient.dark.darkColor()
        gradientView.startColorPoint = CGPoint.init(x: 0.5, y: 0)
        gradientView.endColorPoint = CGPoint.init(x: 0.5, y: 1)
        gradientView.pictureView = patternView
        
        return gradientView
    }
    
    func grayScale(point:CGPoint) -> CGFloat {
        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context!.translateBy(x: -point.x, y: -point.y)
        layer.render(in: context!)
        
        let scale = (CGFloat(pixel[0])/255.0 + CGFloat(pixel[1])/255.0 + CGFloat(pixel[2])/255.0)/3
        
        return scale
        
    }
}

extension CGPoint : Hashable {
    public var hashValue: Int {
        return Int(x).hashValue << 32 ^ Int(y).hashValue
    }
    
    func strideUpY(to limit : CGFloat = 7) -> StrideTo<CGFloat> {
        return stride(from: y.rounded(), to: y.rounded() + limit, by: 1)
    }
    
    func strideDownY(to limit : CGFloat = 7) -> StrideTo<CGFloat> {
       return stride(from: y.rounded(), to: y.rounded() - limit, by: -1)
    }
    
    func strideUpX(to limit : CGFloat = 7) -> StrideTo<CGFloat> {
        return stride(from: x.rounded(), to: x.rounded() + limit, by: 1)
    }
    
    func strideDownX(to limit : CGFloat = 7) -> StrideTo<CGFloat> {
        return stride(from: x.rounded(), to: x.rounded() - limit, by: -1)
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
        return (miles + 25) * 1.60934
    }
    
    class func largerThanMax(radius: Double) -> Bool {
        return (radius / 1.60934) >= 1000 // miles
    }
}
