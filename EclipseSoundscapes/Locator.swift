//
//  Locationator.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 5/25/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import UIKit
import CoreLocation


/// Delegate for Locator class
public protocol LocatorDelegate: NSObjectProtocol {
    
    /// Present Alert due to lack of permission or error
    ///
    /// - Parameter alert: Alert
    func presentAlert(_ alert : UIViewController)
    
    
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
public class Locator : NSObject {
    
    static var LocationAuthorization : CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    /// CLLocation Manager Object
    fileprivate var locationManager  : CLLocationManager!
    
    /// Delegate for Location Updates/Errors/Alerts
    weak var delegate : LocatorDelegate?
    
    /// Begin gathering Information on the User's Location
    ///     - Start Recording if Authorzation Status is:
    ///             - .authorizedWhenInUse
    ///             - .authorizedAlways
    ///     - Return error if Authorzation Status is either:
    ///             - .denied
    ///             - .restricted
    ///     - Request Authorization to get Location if Status is:
    ///             - .notDetermined
    func getLocation(){
        
        let status =  CLLocationManager.authorizationStatus()
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            self.locationManager.requestLocation()
            
            break
        case .denied,.restricted:
            
            if checkLocationServices() {//App Location Permission Denied
                
                self.delegate?.presentAlert(locationPermissionDeniedAlert())
            }
            else { // Location Permission Denied
                self.delegate?.presentAlert(privacySettingsAlert())
                
            }
            
            break
        case .notDetermined:
            
            if checkLocationServices(){
                self.locationManager = CLLocationManager()
                self.locationManager.delegate = self
                self.locationManager.requestWhenInUseAuthorization()
            }
            break
        }
        
    }

    
    
    /// Check if Location Services are enabled
    ///
    /// - Returns: Current Status of Location Services
    fileprivate func checkLocationServices() -> Bool{
        return CLLocationManager.locationServicesEnabled()
    }
    
    
    /// Build Alert for opening App's Settings
    ///
    /// - Returns: App Setting Alert
    func locationPermissionDeniedAlert() -> UIViewController {
        return UIAlertController.appSettingsAlert(title: "Location Permission Denied", message: "Turn on Location in Settings > EclipseSignal > Location to allow us to determine your current location")
    }
    
    
    /// Build Alert for opening Privacy Settings
    ///
    /// - Returns: Privacy Setting Alert
    func privacySettingsAlert() -> UIViewController {
        let alert = UIAlertController(title: "Location Services Off", message: "Turn on Location Services in Settings > Privacy to allow us to determine your current location", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) in
            self.openLocation()
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alert
    }
    
}

extension Locator : CLLocationManagerDelegate {
    
    
    /// Handle Changes to Location Authorization
    ///     - Start Recording if Authorzation Status is:
    ///             - .authorizedWhenInUse
    ///             - .authorizedAlways
    ///     - Return error if Authorzation Status is either:
    ///             - .denied
    ///             - .restricted
    ///     - Request Authorization to get Location if Status is:
    ///             - .notDetermined
    /// - Parameters:
    ///   - manager: CLLocationManager
    ///   - status: CLAuthorizationStatus
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
            
            break
        case .denied,.restricted:
            
            if checkLocationServices() { // Location Permission Denied
                self.delegate?.presentAlert(privacySettingsAlert())
            }
            else { //App Location Permission Denied
                
                self.delegate?.presentAlert(locationPermissionDeniedAlert())
            }
            
            break
        case .notDetermined:
            
            self.locationManager.requestWhenInUseAuthorization()
            break
        }
    }
    
    
    /// Store User's Location to the Current Recording
    ///
    /// - Parameters:
    ///   - manager: CLLocationManager
    ///   - locations: Latest Location
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        delegate?.locator(didUpdateBestLocation: location)
        
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

extension Locator {
    
    /// Source:
    ///    Jeon Suyeol, devxoul, Open Settings > Privacy > Location Service in iOS 10, (2017), GitHubGist file
    ///    https://gist.github.com/devxoul/49d7d8414bce22a7b629a16be9e7f8c0
    
    fileprivate func openLocation() {
        guard let workspaceClass = NSClassFromString("LSApplicationWorkspace") else { return }
        let workspace: AnyObject = execute(workspaceClass, "defaultWorkspace")
        let url = URL(string: "Prefs:root=Privacy&path=LOCATION")!
        execute2(workspace, "openSensitiveURL:withOptions:", with: url)
    }
    
    private func getImplementation(_ owner: AnyObject, _ name: String) -> IMP {
        let selector = Selector(name)
        let method: Method
        if let cls = owner as? AnyClass {
            method = class_getClassMethod(cls, selector)
        } else {
            let cls: AnyClass = object_getClass(owner)!
            method = class_getInstanceMethod(cls, selector)
        }
        return method_getImplementation(method)
    }
    
    private func execute(_ owner: AnyObject, _ name: String, with arg1: Any? = nil, arg2: Any? = nil, arg3: Any? = nil) -> AnyObject {
        let implementation = getImplementation(owner, name)
        typealias Function = @convention(c) (AnyObject, Selector, Any?, Any?, Any?) -> Unmanaged<AnyObject>
        let function = unsafeBitCast(implementation, to: Function.self)
        return function(owner, Selector(name), arg1, arg2, arg3).takeRetainedValue()
    }
    
    private func execute2(_ owner: AnyObject, _ name: String, with arg1: Any? = nil, arg2: Any? = nil, arg3: Any? = nil) {
        let implementation = getImplementation(owner, name)
        typealias Function = @convention(c) (AnyObject, Selector, Any?, Any?, Any?) -> Void
        let function = unsafeBitCast(implementation, to: Function.self)
        return function(owner, Selector(name), arg1, arg2, arg3)
    }
    
}


