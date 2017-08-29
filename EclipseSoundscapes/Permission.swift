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

public enum PermissionType: Int {
    case notification
    case locationAlways
    case locationWhenInUse
    case locationWithBackground
}

//MARK: - Interface
public struct Permission {
    
    static public func isAllowPermission(_ permission: PermissionType) -> Bool {
        let permissionManager = PermissionsManager.init()
        return permissionManager.isAuthorizedPermission(permission)
    }
    
    static public func isAllowPermissions(_ permissions: [PermissionType]) -> Bool {
        for permission in permissions {
            if !self.isAllowPermission(permission) {
                return false
            }
        }
        return true
    }
    
    private init() {}
}

class NotificationPermission : PermissionInterface {
    
    func isAuthorized() -> Bool {
        let notificationType = UIApplication.shared.currentUserNotificationSettings!.types
        if notificationType == [] {
            return false
        } else {
            return true
        }
    }
    
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

class LocationPermission: PermissionInterface {
    
    var type: LocationType
    
    enum LocationType {
        case Always
        case WhenInUse
        case AlwaysWithBackground
    }
    
    init(type: LocationType) {
        self.type = type
    }
    
    func isAuthorized() -> Bool {
        
        let status = CLLocationManager.authorizationStatus()
        
        switch self.type {
        case .Always:
            if status == .authorizedAlways {
                return true
            } else {
                return false
            }
        case .WhenInUse:
            if status == .authorizedWhenInUse {
                return true
            } else {
                return false
            }
        case .AlwaysWithBackground:
            if status == .authorizedAlways {
                return true
            } else {
                return false
            }
        }
    }
    
    func request(withComlectionHandler complectionHandler: @escaping ()->()?) {
        
        switch self.type {
        case .Always:
            if PermissionAlwaysAuthorizationLocationHandler.shared == nil {
                PermissionAlwaysAuthorizationLocationHandler.shared = PermissionAlwaysAuthorizationLocationHandler()
            }
            
            PermissionAlwaysAuthorizationLocationHandler.shared!.requestPermission { (authorized) in
                DispatchQueue.main.async {
                    complectionHandler()
                    PermissionAlwaysAuthorizationLocationHandler.shared = nil
                }
            }
            break
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
        case .AlwaysWithBackground:
            if PermissionLocationWithBackgroundHandler.shared == nil {
                PermissionLocationWithBackgroundHandler.shared = PermissionLocationWithBackgroundHandler()
            }
            
            PermissionLocationWithBackgroundHandler.shared!.requestPermission { (authorized) in
                DispatchQueue.main.async {
                    complectionHandler()
                    PermissionLocationWithBackgroundHandler.shared = nil
                }
            }
            break
        }
    }
}

class PermissionsManager: PermissionsManagerInterface {
    
    func isAuthorizedPermission(_ permission: PermissionType) -> Bool {
        let manager = self.getManagerForPermission(permission)
        return manager.isAuthorized()
    }
    
    func requestPermission(_ permission: PermissionType, with complectionHandler: @escaping ()->()) {
        let manager = self.getManagerForPermission(permission)
        manager.request(withComlectionHandler: {
            complectionHandler()
        })
    }
    
    private func getManagerForPermission(_ permission: PermissionType) -> PermissionInterface {
        switch permission {
        case .notification:
            return NotificationPermission()
        case .locationAlways:
            return LocationPermission(type: LocationPermission.LocationType.Always)
        case .locationWhenInUse:
            return LocationPermission(type: LocationPermission.LocationType.WhenInUse)
        case .locationWithBackground:
            return LocationPermission(type: LocationPermission.LocationType.AlwaysWithBackground)
        }
    }
}

class PermissionAlwaysAuthorizationLocationHandler: NSObject, CLLocationManagerDelegate {
    
    static var shared: PermissionAlwaysAuthorizationLocationHandler?
    
    lazy var locationManager: CLLocationManager =  {
        return CLLocationManager()
    }()
    
    var complectionHandler: PermissionAuthorizationHandlerCompletionBlock?
    
    override init() {
        super.init()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if whenInUseNotRealChangeStatus {
            if status == .authorizedWhenInUse {
                return
            }
        }
        
        if status == .notDetermined {
            return
        }
        
        if let complectionHandler = complectionHandler {
            complectionHandler(isAuthorized())
        }
    }
    
    private var whenInUseNotRealChangeStatus: Bool = false
    
    func requestPermission(_ complectionHandler: @escaping PermissionAuthorizationHandlerCompletionBlock) {
        self.complectionHandler = complectionHandler
        
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .notDetermined:
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
            break
        case .authorizedWhenInUse:
            self.whenInUseNotRealChangeStatus = true
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
            break
        default:
            complectionHandler(isAuthorized())
        }
    }
    
    func isAuthorized() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways {
            return true
        }
        return false
    }
    
    deinit {
        locationManager.delegate = nil
    }
}

class PermissionWhenInUseAuthorizationLocationHandler: NSObject, CLLocationManagerDelegate {
    
    static var shared: PermissionWhenInUseAuthorizationLocationHandler?
    
    lazy var locationManager: CLLocationManager =  {
        return CLLocationManager()
    }()
    
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

class PermissionLocationWithBackgroundHandler: PermissionAlwaysAuthorizationLocationHandler {
    
    override func requestPermission(_ complectionHandler: @escaping PermissionAlwaysAuthorizationLocationHandler.PermissionAuthorizationHandlerCompletionBlock) {
        if #available(iOS 9.0, *) {
            locationManager.allowsBackgroundLocationUpdates = true
        }
        super.requestPermission(complectionHandler)
    }
}

extension PermissionAlwaysAuthorizationLocationHandler {
    
    typealias PermissionAuthorizationHandlerCompletionBlock = (Bool) -> Void
}

extension PermissionWhenInUseAuthorizationLocationHandler {
    
    typealias PermissionAuthorizationHandlerCompletionBlock = (Bool) -> Void
}

public protocol PermissionsManagerInterface {
    
    func isAuthorizedPermission(_ permission: PermissionType) -> Bool
    
    func requestPermission(_ permission: PermissionType, with complectionHandler: @escaping ()->())
}

public protocol PermissionInterface {
    
    func isAuthorized() -> Bool
    
    func request(withComlectionHandler complectionHandler: @escaping ()->()?)
}
