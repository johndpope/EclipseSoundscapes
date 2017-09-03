//
//  Permission.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 8/28/17.
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

import Foundation
import MapKit
import UserNotifications



/// Permissions Types for App
///
/// - notification: Notification Permission
/// - locationAlways: Track Location always
/// - locationWhenInUse: Track Location when app is in use
/// - locationWithBackground: Track Location in background
public enum PermissionType: Int {
    case notification
    case locationWhenInUse
}


/// Helper to quicly check is a permission is authorized
public struct Permission {
    
    /// Check if permission is authorized
    ///
    /// - Parameter permission: Permission to check
    /// - Returns: If permission is authorized or not
    static public func isAllowPermission(_ permission: PermissionType) -> Bool {
        let permissionManager = PermissionsManager.init()
        return permissionManager.isAuthorizedPermission(permission)
    }
    
    /// Check if array of permissions are authorized
    ///
    /// - Parameter permissions: Permissions to check
    /// - Returns: If all permissions are authorized or not
    static public func isAllowPermissions(_ permissions: [PermissionType]) -> Bool {
        for permission in permissions {
            if !self.isAllowPermission(permission) {
                return false
            }
        }
        return true
    }
}


/// Notification Permission Manager
class NotificationPermission : PermissionInterface {
    
    
    /// Check if Notifiation Permission is authorized
    ///
    /// - Returns: Authorization Status
    func isAuthorized() -> Bool {
        let notificationType = UIApplication.shared.currentUserNotificationSettings!.types
        if notificationType == [] {
            return false
        } else {
            return true
        }
    }
    
    
    /// Request Notification Permission
    ///
    /// - Parameter complectionHandler: optional completion block after request
    func request(withComlectionHandler complectionHandler: @escaping ()->()?) {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
                DispatchQueue.main.async {
                    complectionHandler()
                }
            }
        } else {
            // Fallback on earlier versions
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            DispatchQueue.main.async {
                complectionHandler()
            }
        }
        
        UIApplication.shared.registerForRemoteNotifications()
    }
    
}

/// Location Permission Manager
class LocationPermission: PermissionInterface {
    
    
    /// Current location type
    var type: LocationType
    
    
    /// Location Permission Types
    ///
    /// - Always: Track Location always (Not Supported)
    /// - WhenInUse: Track Location when app is in use
    /// - AlwaysWithBackground: Track Location in background (Not Supported)
    enum LocationType {
        case Always
        case WhenInUse
        case AlwaysWithBackground
    }
    
    init(type: LocationType) {
        self.type = type
    }
    
    
    /// Check if Location Permission is authorized
    ///
    /// - Returns: Location Permission Status
    func isAuthorized() -> Bool {
        
        let status = CLLocationManager.authorizationStatus()
        
        switch self.type {
        case .WhenInUse:
            if status == .authorizedWhenInUse {
                return true
            } else {
                return false
            }
        case .Always: // Not Supported
            return false
        case .AlwaysWithBackground: // Not Supported
            return false
        }
    }
    
    /// Check if Location Services are enabled
    ///
    /// - Returns: Current Status of Location Services
    func checkLocationServices() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    
    /// Request Location Permission
    ///
    /// - Parameter complectionHandler: optional completion block handler after request
    func request(withComlectionHandler complectionHandler: @escaping ()->()?) {
        
        switch self.type {
        case .WhenInUse:
            if PermissionWhenInUseAuthorizationLocationHandler.shared == nil {
                PermissionWhenInUseAuthorizationLocationHandler.shared = PermissionWhenInUseAuthorizationLocationHandler()
            }
            
            PermissionWhenInUseAuthorizationLocationHandler.shared!.requestPermission { (authorized) in
                DispatchQueue.main.async {
                    complectionHandler()
                    PermissionWhenInUseAuthorizationLocationHandler.shared = nil
                }
            }
            break
        case .Always: // Not Supported
            break
        case .AlwaysWithBackground: // Not Supported
            break
        }
    }
}


/// Permissions Manager
class PermissionsManager: PermissionsManagerInterface {
    
    
    /// Check if permission is authorized
    ///
    /// - Parameter permission: Permission to check
    /// - Returns: If permission is authorized or not
    func isAuthorizedPermission(_ permission: PermissionType) -> Bool {
        let manager = self.getManagerForPermission(permission)
        return manager.isAuthorized()
    }
    
    /// Request Location for given Permission
    ///
    /// - Parameters:
    ///   - permission: Permission to request authorization
    ///   - complectionHandler: optional completion block handler after request
    func requestPermission(_ permission: PermissionType, with complectionHandler: @escaping ()->()) {
        let manager = self.getManagerForPermission(permission)
        manager.request(withComlectionHandler: {
            complectionHandler()
        })
    }
    
    
    /// Get the appropriate manager for the given permission
    ///
    /// - Parameter permission: Permission to requst
    /// - Returns: appropriate manager for the given permission
    private func getManagerForPermission(_ permission: PermissionType) -> PermissionInterface {
        switch permission {
        case .notification:
            return NotificationPermission()
        case .locationWhenInUse:
            return LocationPermission(type: LocationPermission.LocationType.WhenInUse)
        }
    }
}


/// Handler class for Location Permission (When in Use)
class PermissionWhenInUseAuthorizationLocationHandler: NSObject, CLLocationManagerDelegate {
    
    
    /// Static Handler
    static var shared: PermissionWhenInUseAuthorizationLocationHandler?
    
    
    /// Local CLLocation manager
    lazy var locationManager: CLLocationManager =  {
        return CLLocationManager()
    }()
    
    
    /// Optional completion block handler for permission requests
    var complectionHandler: PermissionAuthorizationHandlerCompletionBlock?
    
    override init() {
        super.init()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .notDetermined {
            return
        }
        
        if let complectionHandler = complectionHandler {
            complectionHandler(isAuthorized())
        }
    }
    
    /// Permission Request
    ///
    /// - Parameter complectionHandler: Optional completion block for permission requests
    func requestPermission(_ complectionHandler: @escaping PermissionAuthorizationHandlerCompletionBlock) {
        self.complectionHandler = complectionHandler
        
        let status = CLLocationManager.authorizationStatus()
        if (status == .notDetermined) || (status == .authorizedAlways) {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
        } else {
            complectionHandler(isAuthorized())
        }
    }
    
    /// Status of Location when in use authorization
    ///
    /// - Returns: Location Permission Status
    func isAuthorized() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {
            return true
        }
        return false
    }
    
    deinit {
        locationManager.delegate = nil
    }
}

extension PermissionWhenInUseAuthorizationLocationHandler {
    
    /// Pretyfied Completion Block Alias
    typealias PermissionAuthorizationHandlerCompletionBlock = (Bool) -> Void
}


/// Permission Manager Protocol that all managers must conform to
public protocol PermissionsManagerInterface {
    
    func isAuthorizedPermission(_ permission: PermissionType) -> Bool
    
    func requestPermission(_ permission: PermissionType, with complectionHandler: @escaping ()->())
}


/// Permission Protocol that all interface must conform to
public protocol PermissionInterface {
    
    /// Check if Permission is authorized
    ///
    /// - Returns: Authorization Status
    func isAuthorized() -> Bool
    
    /// Request Permission
    ///
    /// - Parameter complectionHandler: optional completion block after request
    func request(withComlectionHandler complectionHandler: @escaping ()->()?)
}
