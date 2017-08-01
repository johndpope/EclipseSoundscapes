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

class NotificationDataSource : SPRequestPermissionDialogInteractiveDataSource {
    
    override func headerTitle() -> String {
        return "Hello!"
    }
    
    override func headerSubtitle() -> String {
        return "Don't miss the Eclipse. We need your permission to notify you about Eclipse Events."
    }
    
    override func topAdviceTitle() -> String {
        return "Allow permission please. This helps to keep you informed with the Eclipse"
    }
}

var ReminderCategory = "reminder.category"
var ReminderAction = "REMINDER_ACTION"

var ListenCategory = "listen.category"
var ListenAction = "LISTEN_ACTION"


class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let notificationName = notification.request.content.userInfo["NotificationName"] as? Notification.Name {
            postNotification(for: notificationName)
        }
        completionHandler([.sound, .alert])
    }
    
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if let notificationName = response.notification.request.content.userInfo["NotificationName"] as? Notification.Name {
            postNotification(for: notificationName)
        }
        completionHandler()
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        if let notificationName = notification.userInfo?["NotificationName"] as? Notification.Name {
            postNotification(for: notificationName)
        }
        
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        if let notificationName = notification.userInfo?["NotificationName"] as? Notification.Name {
            postNotification(for: notificationName)
        }
    }
    
    func postNotification(for name: Notification.Name){
        NotificationCenter.default.post(name: name, object: nil)
    }

}

class NotificationHelper {
    
    enum Reminder {
        case firstReminder, contact1, totalityReminder, totality
    }
    
    static func checkPermission() -> Bool {
        return SPRequestPermission.isAllowPermission(.notification)
    }
    
    static var isGranted : Bool  {
        return SPRequestPermission.isAllowPermission(.notification) && appGrated
    }
    
    static var appGrated : Bool{
        get {
            return UserDefaults.standard.bool(forKey: "NotificationGranted")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "NotificationGranted")
        }
    }
    
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
        
        var notificationName : Notification.Name!
        var message : String!
        switch  reminder {
        case .firstReminder:
            notificationName = Notification.Name.EclipseFirstReminder
            message = "The Solar Eclipse is going to being soon."
            break
        case .totalityReminder:
            notificationName = Notification.Name.EclipseTotalityReminder
            message = "The Total Solar Eclipse is going to being soon."
        default:
            fatalError("The Correct Reminder was not set for Reminder Notification")
        }
        
        add(with: date, title: "Eclipse Soundscapes", body: message, categoryId: ReminderCategory, notificationName: notificationName)
    }
    
    class func listenNotification(for date: Date, message: String? = nil, reminder: Reminder) {
        
        var body : String!
        
        if let message = message {
            body = message.appending(" Press to listen now.")
        } else {
            body = "The Eclipse has begun! Press to listen now."
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
        
        var notificationName : Notification.Name!
        switch  reminder {
        case .firstReminder:
            notificationName = Notification.Name.EclipseFirstReminder
            break
        case .totalityReminder:
            notificationName = Notification.Name.EclipseTotalityReminder
        default:
            fatalError("The Correct Reminder was not set for Listen Notification")
        }
        
        add(with: date, title: "Eclipse Soundscapes", body: body, categoryId: ListenCategory, notificationName: notificationName)
    }
    
    private class func add(with date: Date, title: String, body: String, categoryId : String? , identifier : String = UUID.init().uuidString, notificationName : Notification.Name) {
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = UNNotificationSound.default()
            content.userInfo = ["NotificationName" : notificationName]
            
            
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
            
            // ios 9
            let notification = UILocalNotification()
            notification.fireDate = date
            notification.alertTitle = title
            notification.alertBody = body
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.userInfo = ["NotificationName" : notificationName]
            
            if let category = categoryId {
                notification.category = category
            }
            
            UIApplication.shared.scheduleLocalNotification(notification)
            print("\(categoryId ?? "") Notification Added")
        }
    }
    
    static func openPlayer() {
        let title = "Eclipse Media Player is about to open in 10 seconds"
        let detail = "Get Ready to listen. Tap to go immediately."
        
        let banner = Banner(title: title, subtitle: detail, image: #imageLiteral(resourceName: "Icon"), backgroundColor: UIColor.init(r: 75, g: 75, b: 75))
        banner.alpha = 1.0
        banner.titleLabel.textColor = .white
        banner.detailLabel.textColor = .white
        
        banner.didDismissBlock = {
            let playbackVC = PlaybackViewController()
            let top = Utility.getTopViewController()
            top.present(playbackVC, animated: true, completion: nil)
        }
        
        banner.isAccessibilityElement = true
        banner.accessibilityElementsHidden = true
        banner.accessibilityLabel = title + detail
    
        banner.show(duration: 10.0)
        
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, banner)
    }
    
}

extension Notification.Name {
    static let EclipseFirstReminder = Notification.Name("EclipseFirstReminder")
    static let EclipseContact1 = Notification.Name("EclipseContact1")
    static let EclipseTotalityReminder = Notification.Name("EclipseTotalityReminder")
    static let EclipseTotality = Notification.Name("EclipseTotality")
}
