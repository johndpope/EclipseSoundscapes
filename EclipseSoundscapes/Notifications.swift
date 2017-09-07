//
//  Notifications.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 7/20/17.
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
import UserNotifications
import BRYXBanner

var ReminderCategory = "reminder.category"
var ReminderAction = "REMINDER_ACTION"

var ListenCategory = "listen.category"
var ListenAction = "LISTEN_ACTION"


class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let reminderRawValue = notification.request.content.userInfo["Reminder"] as? Int {
            NotificationHelper.postNotification(for: Reminder.init(rawValue: reminderRawValue))
        }
        completionHandler([.sound])
    }
    
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if let reminderRawValue = response.notification.request.content.userInfo["Reminder"] as? Int {
            NotificationHelper.postNotification(for: Reminder.init(rawValue: reminderRawValue))
        }
        completionHandler()
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        if let reminderRawValue = notification.userInfo?["Reminder"] as? Int {
            NotificationHelper.postNotification(for: Reminder.init(rawValue: reminderRawValue))
        }
        
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        if let reminderRawValue = notification.userInfo?["Reminder"] as? Int {
            NotificationHelper.postNotification(for: Reminder.init(rawValue: reminderRawValue))
        }
    }
    
    
    
}


/// Types of Notification Reminders
public struct Reminder: OptionSet {
    public let rawValue: Int
    public init(rawValue:Int){ self.rawValue = rawValue}
    
    static let firstReminder = Reminder(rawValue: 1)
    static let contact1 = Reminder(rawValue: 2)
    static let totaltyReminder = Reminder(rawValue: 4)
    static let totality = Reminder(rawValue: 8)
    static let allDone = Reminder(rawValue: 16)
}


/// Handles all Notification posting and permissions statuses
class NotificationHelper {
    
    
    /// Check system wide notification permission status
    ///
    /// - Returns: Status
    static func checkPermission() -> Bool {
        return Permission.isAllowPermission(.notification)
    }
    
    
    /// Status of Notification Permission
    static var isGranted : Bool  {
        return checkPermission() && appGrated
    }
    
    
    /// Checks the application wide notification permission status
    static var appGrated : Bool{
        get {
            return UserDefaults.standard.bool(forKey: "NotificationGranted")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "NotificationGranted")
        }
    }
    
    /// Tracker for if Eclipse Event Reminders have been setup
    static var didSetReminderObservers : Bool {
        get {
            return UserDefaults.standard.bool(forKey: "Reminders")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "Reminders")
        }
    }
    
    
    /// Post notification to observers of the given Reminder
    ///
    /// - Parameters:
    ///   - reminder: Reminder
    ///   - notify: Should Notify Observers
    class func postNotification(for reminder: Reminder, notify: Bool = true){
        
        var name : Notification.Name!
        if reminder == .firstReminder {
            if UserDefaults.standard.bool(forKey: "Contact1Reminder") {
                return
            }
            name = Notification.Name.EclipseFirstReminder
            UserDefaults.standard.set(true, forKey: "Contact1Reminder")
            
        } else if reminder == .contact1 {
            if UserDefaults.standard.bool(forKey: "Contact1Done") {
                return
            }
            name = Notification.Name.EclipseContact1
            UserDefaults.standard.set(true, forKey: "Contact1Done")
            UserDefaults.standard.set(true, forKey: "Contact1Reminder")
            
        } else if reminder == .totaltyReminder {
            if UserDefaults.standard.bool(forKey: "TotalityReminder") {
                return
            }
            name = Notification.Name.EclipseTotalityReminder
            UserDefaults.standard.set(true, forKey: "TotalityReminder")
            UserDefaults.standard.set(true, forKey: "Contact1Done")
            UserDefaults.standard.set(true, forKey: "Contact1Reminder")
            
        } else if reminder == .totality {
            if UserDefaults.standard.bool(forKey: "TotalityDone") {
                return
            }
            name = Notification.Name.EclipseTotality
            UserDefaults.standard.set(true, forKey: "TotalityDone")
            UserDefaults.standard.set(true, forKey: "TotalityReminder")
            UserDefaults.standard.set(true, forKey: "Contact1Done")
            UserDefaults.standard.set(true, forKey: "Contact1Reminder")
            
        } else {
            name = Notification.Name.EclipseAllDone
            UserDefaults.standard.set(true, forKey: "EclipseAllDone")
            UserDefaults.standard.set(true, forKey: "Contact1Reminder")
            UserDefaults.standard.set(true, forKey: "Contact1Done")
            UserDefaults.standard.set(true, forKey: "TotalityReminder")
            UserDefaults.standard.set(true, forKey: "TotalityDone")
        }
        
        if notify {
            NotificationCenter.default.post(name: name, object: nil, userInfo: ["Reminder": reminder])
        }
    }
    
    
    /// Add Observers to the given Reminder
    ///
    /// - Parameters:
    ///   - observer: Observer
    ///   - reminders: Reminder
    ///   - selector: Selector to perform as notification is posted
    static func addObserver(_ observer : Any, reminders : Reminder, selector: Selector){
        
        if reminders.contains(.firstReminder) {
            NotificationCenter.default.addObserver(observer, selector: selector, name: Notification.Name.EclipseFirstReminder, object: nil)
        }
        if reminders.contains(.contact1) {
            NotificationCenter.default.addObserver(observer, selector: selector, name: Notification.Name.EclipseContact1, object: nil)
        }
        if reminders.contains(.totaltyReminder) {
            NotificationCenter.default.addObserver(observer, selector: selector, name: Notification.Name.EclipseTotalityReminder, object: nil)
        }
        if reminders.contains(.totality) {
            NotificationCenter.default.addObserver(observer, selector: selector, name: Notification.Name.EclipseTotality, object: nil)
        }
        if reminders.contains(.allDone) {
            NotificationCenter.default.addObserver(observer, selector: selector, name: Notification.Name.EclipseAllDone, object: nil)
        }
    }
    
    
    /// Remove observer for the given Reminder
    ///
    /// - Parameters:
    ///   - observer: Observer
    ///   - reminders: Reminder to observe
    static func removeObserver(_ observer: Any, reminders: Reminder) {
        if reminders.contains(.firstReminder) {
            cleanNotificationList(reminder: .firstReminder)
            NotificationCenter.default.removeObserver(observer, name: Notification.Name.EclipseFirstReminder, object: nil)
        }
        if reminders.contains(.contact1) {
            cleanNotificationList(reminder: .contact1)
            NotificationCenter.default.removeObserver(observer, name: Notification.Name.EclipseContact1, object: nil)
        }
        if reminders.contains(.totaltyReminder) {
            cleanNotificationList(reminder: .totaltyReminder)
            NotificationCenter.default.removeObserver(observer, name: Notification.Name.EclipseTotalityReminder, object: nil)
        }
        if reminders.contains(.totality) {
            cleanNotificationList(reminder: .totality)
            NotificationCenter.default.removeObserver(observer, name: Notification.Name.EclipseTotality, object: nil)
        }
        if reminders.contains(.allDone) {
            NotificationCenter.default.removeObserver(observer, name: Notification.Name.EclipseAllDone, object: nil)
        }
    }
    
    
    /// Remove Delivered Notifications
    ///
    /// - Parameter reminder: Reminder that the notification is associated to
    private static func cleanNotificationList(reminder: Reminder) {
        if #available(iOS 10.0, *) {
            var identifier : String!
            
            if reminder == .firstReminder {
                identifier = "EclipseSoundscapes.EclipseFirstReminder"
            } else if reminder == .contact1 {
                identifier = "EclipseSoundscapes.EclipseContact1"
            } else if reminder == .totaltyReminder {
                identifier = "EclipseSoundscapes.EclipseTotalityReminder"
            } else {
                identifier = "EclipseSoundscapes.EclipseTotality"
            }
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
        } else {
            // Fallback on earlier versions
            let app = UIApplication.shared
            if var scheduledNotifications = app.scheduledLocalNotifications {
                for i in 0..<scheduledNotifications.count {
                    if let nReminder = scheduledNotifications[i].userInfo?["Reminder"] as? Reminder {
                        if reminder == nReminder {
                            scheduledNotifications.remove(at: i)
                        }
                    }
                }
            }
        }
    }
    
    
    /// Remove observer from recieving notifications
    ///
    /// - Parameter observer: Observer
    static func removeObserver(_ observer: Any) {
        NotificationCenter.default.removeObserver(observer)
    }
    
    
    /// Setup Reminder Notification
    ///
    /// - Parameters:
    ///   - date: Date to fire notification
    ///   - reminder: Reminder associated to the notification
    class func reminderNotification(for date: Date, reminder: Reminder) {
        if #available(iOS 10.0, *) {
            let reminderAction = UNNotificationAction(identifier: ReminderAction, title: "Okay", options: [.destructive])
            let reminderCategory = UNNotificationCategory(identifier: ReminderCategory,actions: [reminderAction],intentIdentifiers: [], options: [])
            UNUserNotificationCenter.current().setNotificationCategories([reminderCategory])
        } else {
            let reminderAction = UIMutableUserNotificationAction()
            reminderAction.identifier = ReminderAction
            reminderAction.title = "Okay"
            reminderAction.activationMode = UIUserNotificationActivationMode.background
            reminderAction.isAuthenticationRequired = false
            reminderAction.isDestructive = true
            
            let eclipseCategory = UIMutableUserNotificationCategory()
            eclipseCategory.identifier = ReminderCategory
            
            eclipseCategory.setActions([reminderAction],
                                       for: UIUserNotificationActionContext.default)
            
            let categories = NSSet(object: eclipseCategory) as! Set<UIUserNotificationCategory>
            
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: categories)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        
        var message : String!
        if reminder == .firstReminder {
            message = "The Solar Eclipse is going to begin soon."
        } else {
            message = "The Total Solar Eclipse is going to begin soon."
        }
        add(with: date, title: "Eclipse Soundscapes", body: message, categoryId: ReminderCategory, reminder: reminder)
    }
    
    /// Setup Listen Notification
    ///
    /// - Parameters:
    ///   - date: Date to fire notification
    ///   - reminder: Reminder associated to the notification
    class func listenNotification(for date: Date, reminder: Reminder) {
        
        var body : String!
        
        if reminder == .contact1 {
            body = "The Solar Eclipse has begun! Press to listen now."
        } else {
            body = "The Total Solar Eclipse has begun! Press to listen now."
        }
        
        if #available(iOS 10.0, *) {
            let listenAction = UNNotificationAction(identifier: ListenAction, title: "Listen Now", options: [.authenticationRequired,.foreground])
            let listenCategory = UNNotificationCategory(identifier: ListenCategory,actions: [listenAction],intentIdentifiers: [], options: [])
            UNUserNotificationCenter.current().setNotificationCategories([listenCategory])
        } else {
            let listenAction = UIMutableUserNotificationAction()
            listenAction.identifier = ListenAction
            listenAction.title = "Listen Now"
            listenAction.activationMode = UIUserNotificationActivationMode.foreground
            listenAction.isAuthenticationRequired = true
            listenAction.isDestructive = false
            
            let eclipseCategory = UIMutableUserNotificationCategory()
            eclipseCategory.identifier = ListenCategory
            
            eclipseCategory.setActions([listenAction],
                                       for: UIUserNotificationActionContext.default)
            
            let categories = NSSet(object: eclipseCategory) as! Set<UIUserNotificationCategory>
            
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: categories)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        add(with: date, title: "Eclipse Soundscapes", body: body, categoryId: ListenCategory, reminder: reminder)
    }
    
    
    /// Register notification to application
    ///
    /// - Parameters:
    ///   - date: Date to fire notification
    ///   - title: Notification's title
    ///   - body: Notification's body
    ///   - categoryId: Notification's category id
    ///   - reminder: Reminder associated to the notification
    private class func add(with date: Date, title: String, body: String, categoryId : String?, reminder: Reminder) {
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = UNNotificationSound.default()
            content.userInfo = ["Reminder": reminder.rawValue]
            
            var identifier : String!
            
            if reminder == .firstReminder {
                identifier = "EclipseSoundscapes.EclipseFirstReminder"
            } else if reminder == .contact1 {
                identifier = "EclipseSoundscapes.EclipseContact1"
            } else if reminder == .totaltyReminder {
                identifier = "EclipseSoundscapes.EclipseTotalityReminder"
            } else {
                identifier = "EclipseSoundscapes.EclipseTotality"
            }
            
            if let category = categoryId {
                content.categoryIdentifier = category
            }
            
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: {
                (errorObject) in
                if let error = errorObject{
                    print("Error \(error.localizedDescription) in notification \(identifier)")
                } else {
                    print("\(categoryId ?? "") Notification Added")
                }
            })
            
            
            
        } else {
            
            let app = UIApplication.shared
            
            if let scheduledNotifications = app.scheduledLocalNotifications {
                for notification in scheduledNotifications {
                    if let nReminder = notification.userInfo?["Reminder"] as? Reminder {
                        if reminder == nReminder {
                            app.cancelLocalNotification(notification)
                        }
                    }
                }
            }
            
            // ios 9
            let notification = UILocalNotification()
            notification.fireDate = date
            notification.alertTitle = title
            notification.alertBody = body
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.userInfo = ["Reminder": reminder.rawValue]
            
            if let category = categoryId {
                notification.category = category
            }
            
            UIApplication.shared.scheduleLocalNotification(notification)
            print("\(categoryId ?? "") Notification Added")
        }
    }
}

extension Notification.Name {
    static let EclipseFirstReminder = Notification.Name("EclipseFirstReminder")
    static let EclipseContact1 = Notification.Name("EclipseContact1")
    static let EclipseTotalityReminder = Notification.Name("EclipseTotalityReminder")
    static let EclipseTotality = Notification.Name("EclipseTotality")
    static let EclipseAllDone = Notification.Name("EclipseAllDone")
}
