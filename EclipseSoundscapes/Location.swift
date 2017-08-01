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
class Location {
    
    static var isGranted : Bool  {
        return SPRequestPermission.isAllowPermission(.locationWhenInUse) && appGrated
    }
    
    static var appGrated : Bool{
        get {
           return UserDefaults.standard.bool(forKey: "LocationGranted")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "LocationGranted")
        }
    }
    
    struct string {
        static let general = " You don’t want to miss this amazing astronomical event! We’ll need your location to continue. Press to Continue."
        static let denied = "Location Services is Denied. Press to Continue"
        static let network = "Nertork Error Occured. Press to Retry"
        static let locationUnknown = "Locating taking longer than Normal."
        static let unkown = "Error Occured. Press to Retry"
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
}



class LocationDataSource : SPRequestPermissionDialogInteractiveDataSource {
    
    override func headerTitle() -> String {
        return "Hello!"
    }
    
    override func headerSubtitle() -> String {
        return "Don't miss the Eclipse. We need your location to proceed"
    }
    
    override func topAdviceTitle() -> String {
        return "Allow permission please. This helps to keep you informed with the Eclipse"
    }
}

typealias PermissionShowedCompletion = ()->Void
typealias PermissionClosedCompletion = ()->Void

class LocationManager : NSObject {
    
    private static let manager = LocationManager()
    
    private var cLManager = CLLocationManager()
    
    /// Delegate for Location Updates/Errors/Alerts
    
    private var observers = [String:LocationDelegate?]()
    
    private var timer : Timer?
    
    fileprivate var isReoccuring = false
    
    private var interval : TimeInterval = 30//15*60 // 15 minutes
    
    
    enum DelegateAction {
        case notGranted, granted, location, error
    }
    
    override init() {
        super.init()
        cLManager.delegate = self
    }

    static func addObserver(_ delegate : LocationDelegate) -> String{
        let key = UUID.init().uuidString
        manager.observers.updateValue(delegate, forKey: key)
        return key
    }
    
    static func removeObserver(key: String?) {
        guard let delegateKey = key else {
            return
        }
        manager.observers.removeValue(forKey: delegateKey)
    }
    
    static func getLocation(withAccuracy accuracy: CLLocationAccuracy = kCLLocationAccuracyBest, reocurring: Bool = true) {
        
        manager.cLManager.desiredAccuracy = accuracy
        manager.isReoccuring = reocurring
        
        manager.request()
    }
    
    
    @objc private func request() {
        if Location.isGranted {
            self.cLManager.requestLocation()
        } else {
            LocationManager.stopLocating()
            post(action: .notGranted)
        }
        timer?.invalidate()
    }
    
    fileprivate func reoccuringRequests() {
        if #available(iOS 10.0, *) {
            timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false, block: { (timer) in
                self.request()
            })
        } else {
            // Fallback on earlier versions
            timer = Timer.init(timeInterval: interval, target: self, selector: #selector(request), userInfo: nil, repeats: false)
        }
    }
    
    static func stopLocating() {
        manager.cLManager.stopUpdatingLocation()
        manager.timer?.invalidate()
        manager.timer = nil
    }
    
    fileprivate func post(action : DelegateAction, value : Any? = nil) {
        for observer in observers.values {
            if let delegate = observer {
                switch action {
                case .location:
                    delegate.locator(didUpdateBestLocation: value as! CLLocation)
                    break
                case .granted:
                    delegate.didGrant()
                    break
                case .error:
                    delegate.locator(didFailWithError: value as! Error)
                    break
                case .notGranted:
                    delegate.notGranted()
                    break
                }
                
            }
        }
    }
    
    static func permission(on controller: UIViewController) {
        SPRequestPermission.dialog.interactive.present(on: controller, with: [.locationWhenInUse], dataSource: LocationDataSource(), delegate: manager)
    }
}

extension LocationManager : CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        self.post(action: .location, value: location)
        
        if isReoccuring {
            reoccuringRequests()
        }
        
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.post(action: .error, value: error)
    }
}

extension LocationManager : SPRequestPermissionEventsDelegate {
    public func didHide() {
        if Location.isGranted {
            post(action: .granted)
            LocationManager.getLocation()
        } else {
            post(action: .notGranted)
        }
    }
    
    public func didAllowPermission(permission: SPRequestPermissionType) {
        Location.appGrated = true
    }
    
    public func didDeniedPermission(permission: SPRequestPermissionType) {
        Location.appGrated = false
    }
    
    public func didSelectedPermission(permission: SPRequestPermissionType) {
        
    }
}



