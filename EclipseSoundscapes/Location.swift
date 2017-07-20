//
//  Location.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 5/25/17.
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
    
    /// If User has diabled location updates
    func notGranted()
    
    /// If User has granted location updates
    func didGrant()
}

/// Handles Obtaining the User's Location
public class Location : NSObject {
    
    static var isGranted = false
    
    
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
    
    public override init() {
        super.init()
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        
        Location.isGranted = SPRequestPermission.isAllowPermission(.locationWhenInUse)
    }
    
    /// Begin gathering Information on the User's Location
    func getLocation(withAccuracy accuracy: CLLocationAccuracy = kCLLocationAccuracyBest, reocurring: Bool = true) {
        self.locationManager.desiredAccuracy = accuracy
        if reocurring {
            isReoccuring = true
            setupReoccuringRequests()
        }
        request()
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
        if Location.isGranted {
            self.locationManager.requestLocation()
        } else {
            stopLocating()
            self.delegate?.notGranted()
        }
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
    
    func permission(on controller: UIViewController) {
        SPRequestPermission.dialog.interactive.present(on: controller, with: [.locationWhenInUse], dataSource: LocationDataSource(), delegate: self)
        controller.view.isAccessibilityElement = false
    }
    
    public func stopLocating() {
        self.locationManager.stopUpdatingLocation()
        self.timer?.invalidate()
        self.timer = nil
    }
    
}

extension Location : SPRequestPermissionEventsDelegate {
    public func didHide() {
        if Location.checkPermission() {
            Location.isGranted = true
            self.delegate?.didGrant()
            getLocation()
        } else {
            Location.isGranted = false
            self.delegate?.notGranted()
        }
    }
    
    public func didAllowPermission(permission: SPRequestPermissionType) {
        
    }
    
    public func didDeniedPermission(permission: SPRequestPermissionType) {
        
    }
    
    public func didSelectedPermission(permission: SPRequestPermissionType) {
        
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
