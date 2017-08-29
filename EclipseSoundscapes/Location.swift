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
import MapKit

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
    
    /// Ask the User if they would like to be put on the path of Totality at the closest point from them
    func notOnToaltiyPath()
    
    /// If User has diabled location updates
    func notGranted()
    
    /// If User has granted location updates
    func didGrant()
    
}

/// Handles Obtaining the User's Location
class Location {
    
    static func checkPermission() -> Bool {
        return Permission.isAllowPermission(.locationWhenInUse)
    }
    
    static var isGranted : Bool  {
        return checkPermission() && appGrated
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
        static let locationUnknown = "Locating taking longer than Normal"
        static let unkown = "Error Occured. Press to Retry"
    }
    
    /// Check if Location Services are enabled
    ///
    /// - Returns: Current Status of Location Services
    fileprivate func checkLocationServices() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
}

typealias PermissionShowedCompletion = ()->Void
typealias PermissionClosedCompletion = ()->Void

class LocationManager : NSObject {
    
    private static var DEBUG = false
    
    static var eclispeDate : Date? {
        get {
            let eclipseAfterDateString = "2017-08-22"
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.date(from: eclipseAfterDateString)
        }
    }
    
    
    fileprivate var MainLocation: CLLocation? {
        didSet {
            UserDefaults.standard.set(MainLocation?.coordinate.latitude, forKey: "LastLat")
            UserDefaults.standard.set(MainLocation?.coordinate.longitude, forKey: "LastLon")
        }
    }
    
    fileprivate static var _isUsersLocation = true
    
    static var isUsersLocation : Bool {
        return _isUsersLocation
    }
    
    fileprivate static var shouldCheckEclipseTimes  = false
    
    fileprivate static let manager = LocationManager()
    
    private var cLManager = CLLocationManager()
    
    /// Delegate for Location Updates/Errors/Alerts
    
    private var observers = [Int:LocationDelegate?]()
    
    private var timer : Timer?
    
    fileprivate var isReoccuring = false
    
    private var interval : TimeInterval = 15*60 // 15 minutes
    private static var preNotificationOffset : Double = 60*2 // 2 Mintues for reminder notifications
    private static var WINDOW_OF_NOTIFICATION : Double = 60*7 // 7 minute window for giving notifications
    
    
    enum DelegateAction {
        case notGranted, granted, location, error, notOnPath
    }
    
    override init() {
        super.init()
        cLManager.delegate = self
    }
    
    static func addObserver(_ delegate : LocationDelegate){
        print("Delegate hash value: \(delegate.hash)")
        manager.observers.updateValue(delegate, forKey: delegate.hash)
    }
    
    static func removeObserver(_ delegate: LocationDelegate?) {
        guard let delegateKey = delegate?.hash else {
            return
        }
        manager.observers.removeValue(forKey: delegateKey)
    }
    
    static func removeAll() {
        manager.observers.removeAll()
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
    
    fileprivate static func stopLocating() {
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
                case .notOnPath:
                    delegate.notOnToaltiyPath()
                }
                
            }
        }
    }
    
    static func permission(on controller: UIViewController) {
        
        controller.present(PermissionViewController.show(with: [.locationWhenInUse], completion: { 
            LocationManager.manager.didHide()
        }), animated: true, completion: nil)
        
    }
    
    static func getClosestLocation() {
        stopLocating()
        guard let lat = UserDefaults.standard.object(forKey: "LastLat") as? Double, let lon = UserDefaults.standard.object(forKey: "LastLon") as? Double else {
            return
        }
        LocationManager._isUsersLocation = false
        let location = closesPointOnPath(from: CLLocation(latitude: lat, longitude: lon))
        LocationManager.manager.MainLocation = location
        LocationManager.manager.post(action: .location, value: location)
    }
    
    @discardableResult
    private static func closesPointOnPath(from location : CLLocation) -> CLLocation {
        
        let eclipseJson = loadPolylines()
        
        var shortest : CLLocation!
        var shortestDistance = Double.infinity
        
        for latlng in eclipseJson! {
            let point = CLLocation(latitude: latlng["lat"]!, longitude: latlng["lon"]!)
            let distance = location.distance(from: point)
            
            if distance < shortestDistance {
                shortestDistance = distance
                shortest = point
            }
        }
        
        return shortest
    }
    
    private static func loadPolylines() -> [Dictionary<String, Double>]? {
        guard let file = Bundle.main.url(forResource: "MainEclipsePolyline", withExtension: ".json") else {
            return nil
        }
        do {
            let data = try Data(contentsOf: file)
            let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [Dictionary<String, Double>]
            
            return json
            
        } catch {
            return nil
        }
    }
    
    fileprivate static func buildNotificationTimes() {
        if UserDefaults.standard.bool(forKey: "EclipseAllDone") {
            return
        }
        
        guard let location = LocationManager.manager.MainLocation else {
            return
        }
        var notificationLocation : CLLocation!
        var isValid = true
        
        var timeGenerator = EclipseTimeGenerator(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        switch timeGenerator.eclipseType {
        case .none:
            LocationManager.manager.post(action: .notOnPath, value: nil)
            notificationLocation = closesPointOnPath(from: location)
            isValid = false
            break
        case .partial :
            notificationLocation = closesPointOnPath(from: location)
            isValid = false
            break
        case .full :
            break
        }
        
        if !isValid {
            timeGenerator = EclipseTimeGenerator(latitude: notificationLocation.coordinate.latitude, longitude: notificationLocation.coordinate.longitude)
        }
        
        
        setNotification(generator: timeGenerator)
        
    }
    
    static var tempDate : Date!
    
    private static func setNotification(generator: EclipseTimeGenerator) {
        
        if UserDefaults.standard.bool(forKey: "EclipseAllDone") {
            return
        }
        
        guard let c1 = generator.contact1.eventDate(), let totality = generator.contact2.eventDate(), let end = generator.contact3.eventDate() else {
            return
        }
        
        if LocationManager.DEBUG {
            tempDate = Date()
            
            if tempDate >= end {
                return
            }
            
            let future1 = tempDate.addingTimeInterval(0.5*60)
            let future2 = tempDate.addingTimeInterval(1*60)
            let future3 = tempDate.addingTimeInterval(3*60)
            let future4 = tempDate.addingTimeInterval(3.5*60)
            
            
            if !UserDefaults.standard.bool(forKey: "Contact1Reminder") {
                //            NotificationHelper.reminderNotification(for: c1.addingTimeInterval(-LocationManager.preNotificationOffset), reminder: .firstReminder)
                NotificationHelper.reminderNotification(for: future1, reminder: .firstReminder)
            }
            
            if !UserDefaults.standard.bool(forKey: "Contact1Done") {
                //            NotificationHelper.listenNotification(for: c1, reminder: .contact1)
                NotificationHelper.listenNotification(for: future2, reminder: .contact1)
            }
            
            if !UserDefaults.standard.bool(forKey: "TotalityReminder") {
                //            NotificationHelper.reminderNotification(for: totality.addingTimeInterval(-LocationManager.preNotificationOffset), reminder: .totaltyReminder)
                NotificationHelper.reminderNotification(for: future3, reminder: .totaltyReminder)
            }
            
            if !UserDefaults.standard.bool(forKey: "TotalityDone") {
                //            NotificationHelper.listenNotification(for: totality, reminder: .totality)
                NotificationHelper.listenNotification(for: future4, reminder: .totality)
            }

        } else {
            
            let today = Date()
            
            if today >= totality {
                return
            }
            
            let totalityOffsetDate = totality.addingTimeInterval(-(10 + 120)) // 2 Minutes and 10 seconds before the eclipse totality
            let totalityReminderDate = totality.addingTimeInterval(-LocationManager.preNotificationOffset * 2)
            
            if !UserDefaults.standard.bool(forKey: "TotalityDone") {
                NotificationHelper.listenNotification(for: totalityOffsetDate, reminder: .totality)
                
                print("Totality Notification Scheduled")
            }
            
            let toalityPreDate = totalityReminderDate
            if today >= toalityPreDate {
                return
            }
            
            if !UserDefaults.standard.bool(forKey: "TotalityReminder") {
                NotificationHelper.reminderNotification(for: toalityPreDate, reminder: .totaltyReminder)
                print("TotalityPre Notification Scheduled")
            }
            
            if today >= c1 {
                return
            }
            
            let c1OffsetDate = c1.addingTimeInterval(-10) // 10 seconds before the contact 1
            let c1ReminderDate = c1.addingTimeInterval(-LocationManager.preNotificationOffset)
            
            if !UserDefaults.standard.bool(forKey: "Contact1Done") {
                NotificationHelper.listenNotification(for: c1OffsetDate, reminder: .contact1)
                print("Contact 1 Notification Scheduled")
            }
        
            let contact1PreDate = c1ReminderDate
            if today >= contact1PreDate {
                return
            }
            
            if !UserDefaults.standard.bool(forKey: "Contact1Reminder") {
                NotificationHelper.reminderNotification(for: contact1PreDate, reminder: .firstReminder)
                print("Contact 1 Pre Notification Scheduled")
            }
            
        }
    }
    
    static func checkEclipseDates() {
        if UserDefaults.standard.bool(forKey: "EclipseAllDone") {
            NotificationHelper.postNotification(for: .allDone)
            return
        }
        
        if let eclipseAfterDate = LocationManager.eclispeDate {
            if Date() >= eclipseAfterDate {
                NotificationHelper.postNotification(for: .allDone)
                return
            }
        }
        
        guard let lat = UserDefaults.standard.object(forKey: "LastLat") as? Double, let lon = UserDefaults.standard.object(forKey: "LastLon") as? Double else {
            LocationManager.shouldCheckEclipseTimes = true
            return
        }
        let location = CLLocation.init(latitude: lat, longitude: lon)
        
        var isValid = true
        
        var timeGenerator = EclipseTimeGenerator(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        var fullEclipseLocation : CLLocation!
        switch timeGenerator.eclipseType {
        case .none, .partial:
            fullEclipseLocation = closesPointOnPath(from: location)
            isValid = false
            break
        default :
            break
        }
        
        if !isValid {
            timeGenerator = EclipseTimeGenerator(latitude: fullEclipseLocation.coordinate.latitude, longitude: fullEclipseLocation.coordinate.longitude)
        }
        
        guard let c1 = timeGenerator.contact1.eventDate(), let totality = timeGenerator.contact2.eventDate(), let done = timeGenerator.contact3.eventDate() else {
            return
        }
        
        let currentDate = Date()
        
        if currentDate >= done {
            NotificationHelper.postNotification(for: .allDone)
            return
        }
        
        if LocationManager.DEBUG {
            
            if let tempDate = LocationManager.tempDate {
                if currentDate >= tempDate.addingTimeInterval(3.5*60) {
                    if !UserDefaults.standard.bool(forKey: "TotalityDone") {
                        NotificationHelper.postNotification(for: .totality)
                        return
                    }
                }
                
                if currentDate >= tempDate.addingTimeInterval(3*60) {
                    if !UserDefaults.standard.bool(forKey: "TotalityReminder") {
                        NotificationHelper.postNotification(for: .totaltyReminder)
                        return
                    }
                }
                
                if currentDate >= tempDate.addingTimeInterval(1*60) {
                    if !UserDefaults.standard.bool(forKey: "Contact1Done") {
                        NotificationHelper.postNotification(for: .contact1)
                        return
                    }
                }
                
                
                if currentDate >= tempDate.addingTimeInterval(0.5*60){
                    if !UserDefaults.standard.bool(forKey: "Contact1Reminder") {
                        NotificationHelper.postNotification(for: .firstReminder)
                        return
                    }
                }
            }
        } else {
            
            let totalityOffsetDate = totality.addingTimeInterval(-(10 + 120)) // 2 Minutes and 10 seconds before the eclipse totality
            let totalityReminderDate = totality.addingTimeInterval(-LocationManager.preNotificationOffset * 2)
            
            if currentDate >= totalityOffsetDate {
                if !UserDefaults.standard.bool(forKey: "TotalityDone") {
                    NotificationHelper.postNotification(for: .totality, notify: currentDate >= totalityOffsetDate.WINDOW_OF_NOTIFICATION)
                    return
                }
            }
            
            if currentDate >= totalityReminderDate {
                if !UserDefaults.standard.bool(forKey: "TotalityReminder") {
                    NotificationHelper.postNotification(for: .totaltyReminder)
                    return
                }
            }
            
            let c1OffsetDate = c1.addingTimeInterval(-10) // 10 seconds before the contact 1
            let c1ReminderDate = c1.addingTimeInterval(-LocationManager.preNotificationOffset)
            
            if currentDate >= c1OffsetDate {
                
                if !UserDefaults.standard.bool(forKey: "Contact1Done") {
                    NotificationHelper.postNotification(for: .contact1, notify: currentDate >= c1OffsetDate.WINDOW_OF_NOTIFICATION)
                    return
                }
            }
            
            
            if currentDate >= c1ReminderDate {
                if !UserDefaults.standard.bool(forKey: "Contact1Reminder") {
                    NotificationHelper.postNotification(for: .firstReminder)
                    return
                }
            }
        }
        
    }
}

extension LocationManager : CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        self.post(action: .location, value: location)
        LocationManager._isUsersLocation = true
        LocationManager.manager.MainLocation = location
        LocationManager.buildNotificationTimes()
        
        if isReoccuring {
            reoccuringRequests()
        }
        
        if LocationManager.shouldCheckEclipseTimes {
            LocationManager.checkEclipseDates()
            LocationManager.shouldCheckEclipseTimes = false
        }
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.post(action: .error, value: error)
        LocationManager.stopLocating()
    }
}

extension LocationManager {
    func didHide() {
        if Location.isGranted {
            post(action: .granted)
            LocationManager.getLocation()
        } else {
            post(action: .notGranted)
        }
    }
}

extension Date {
    var WINDOW_OF_NOTIFICATION: Date {
        return self.addingTimeInterval(60*1.5) // 7 Minute window to give notification to user
    }
}


