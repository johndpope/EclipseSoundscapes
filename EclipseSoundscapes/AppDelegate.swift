//
//  AppDelegate.swift
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
import AudioKit
import UserNotifications
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var notificationDelegate = NotificationDelegate()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Crashlytics.start(withAPIKey: Utility.getFile("fabric.apikey", type: "")!)
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = notificationDelegate
            UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (requests) in
                print(requests.count)
                print(requests.debugDescription)
            })
        } else {
            print(application.scheduledLocalNotifications?.count ?? "No Notification scheduled")
            print(application.scheduledLocalNotifications?.debugDescription ?? "")
        }
        
        if !UserDefaults.standard.bool(forKey: "WalkThrough") {
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.makeKeyAndVisible()
            window?.rootViewController = WalkthroughViewController()
        }
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        LocationManager.checkEclipseDates()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        notificationDelegate.application(application, handleActionWithIdentifier: identifier, for: notification, completionHandler: completionHandler)
    }
    
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        notificationDelegate.application(application, didReceive: notification)
    }

    
    var shouldSupportAllOrientation = false
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if (shouldSupportAllOrientation == true){
            return UIInterfaceOrientationMask.all
        }
        return UIInterfaceOrientationMask.portrait
    }
}
