//
//  Location.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 5/25/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import UIKit
import CoreLocation

/// Delegate for Locator class
public protocol LocationDelegate: NSObjectProtocol {
    
    /// Update of user's lastest location
    ///
    /// - Parameter:
    ///   - location: Best last Location
    func locator(didUpdateBestLocation location: CLLocation)
    
    /// Update of user's lastest location failed
    ///
    /// - Parameter:
    ///   - error: Error trying to get user's last location
    func locator(didFailWithError error: Error)
}

/// Handles Obtaining the User's Location
public class Location : NSObject {
    
    /// CLLocation Manager Object
    fileprivate var locationManager  : CLLocationManager!
    
    /// Delegate for Location Updates/Errors/Alerts
    weak var delegate : LocationDelegate?
    
    private var timer : Timer?
    
    var isReoccuring = false
    var interval : TimeInterval = 60 //30*60 // 30 minutes
    
    struct string {
        static let general = "Don't miss the Eclipse. We need your location to proceed. Press to Continue."
        static let denied = "Location Services is Denied. Press to Continue"
        static let network = "Nertork Error Occured. Press to Retry"
        static let locationUnknown = "Locating taking longer than Normal."
        static let unkown = "Error Occured. Press to Retry"
    }
    
    /// Begin gathering Information on the User's Location
    func getLocation(withAccuracy accuracy: CLLocationAccuracy = kCLLocationAccuracyBest, reocurring: Bool = true) {
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = accuracy
        isReoccuring = reocurring
        self.locationManager.requestLocation()
    }

    fileprivate func setupReoccuringRequests() {
        if #available(iOS 10.0, *) {
            timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false, block: { (timer) in
                self.request()
            })
        } else {
            // Fallback on earlier versions
            timer = Timer.init(timeInterval: interval, target: self, selector: #selector(request), userInfo: nil, repeats: false)
        }
    }
    
   @objc private func request() {
        self.locationManager.requestLocation()
    }
    
    /// Check if Location Services are enabled
    ///
    /// - Returns: Current Status of Location Services
    fileprivate func checkLocationServices() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    static func checkPermission() -> Bool {
        return SPRequestPermission.isAllowPermission(.locationWhenInUse)
    }
    
    static func permission(on controller: UIViewController) {
        SPRequestPermission.dialog.interactive.present(on: controller, with: [.locationWhenInUse], dataSource: LocationDataSource(), delegate: controller as? SPRequestPermissionEventsDelegate)
        controller.view.isAccessibilityElement = false
    }
    
    public func stopLocating() {
        self.locationManager.stopUpdatingLocation()
        self.timer?.invalidate()
        self.timer = nil
    }

}

class LocationDataSource : SPRequestPermissionDialogInteractiveDataSource {
    
    override func headerTitle() -> String {
        return "Hello Soundscapers!"
    }
    
    override func headerSubtitle() -> String {
        return "Don't miss the Eclipse. We need your location to proceed"
    }
    
    override func topAdviceTitle() -> String {
        return "Allow permission please. This helps to keep you informed with the Eclipse"
    }
    
    
}


extension Location : CLLocationManagerDelegate {
    
    
    /// Store User's Location to the Current Recording
    ///
    /// - Parameters:
    ///   - manager: CLLocationManager
    ///   - locations: Latest Location
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        delegate?.locator(didUpdateBestLocation: location)
        
        if isReoccuring {
            setupReoccuringRequests()
        }
        
    }
    
    /// Stop Recording if Location could not be determined
    ///
    /// - Parameters:
    ///   - manager: CLLocationManager
    ///   - error: Error corresponding to failure of finding Location
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.locator(didFailWithError: error)
    }
}
