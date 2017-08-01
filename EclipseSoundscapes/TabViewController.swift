//
//  TabViewController.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 6/12/17.
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
import RevealingSplashView

class TabViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customizeTabBar()
        
        if Location.isGranted {
            LocationManager.getLocation()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        guard let _ = UserDefaults.standard.object(forKey: "PermissionOnce") as? Bool else {
//            
//            SPRequestPermission.dialog.interactive.present(on: self, with: [.notification, .locationWhenInUse],dataSource: AllPermissionDataSource(), delegate: self)
//            
//            UserDefaults.standard.set(true, forKey: "PermissionOnce")
//            return
//        }
    }
    
    func customizeTabBar() {
        self.tabBar.barTintColor = UIColor.init(r: 33, g: 33, b: 33)
        self.tabBar.tintColor = UIColor.init(r: 227, g: 94, b: 5) // Foreground/Background Ratio 4.50053
        
        let width : CGFloat = 50.0
        let height = self.tabBar.frame.height
        
        self.tabBar.isOpaque = false
        self.tabBar.isTranslucent = false
        self.tabBar.accessibilityTraits = UIAccessibilityTraitNone
        
        self.tabBar.selectionIndicatorImage = UIImage.selectionIndiciatorImage(color: UIColor.init(r: 227, g: 94, b: 5), size: CGSize.init(width: width, height: height), lineWidth: 5.0)
        
        for item in self.tabBar.items! {
            item.accessibilityTraits = UIAccessibilityTraitButton
            
        }
        
        self.tabBar.items?[0].accessibilityLabel = "My Eclipse Info"
        
        
    }
    
    func splash() {
        let revealingSplashView = RevealingSplashView(iconImage: #imageLiteral(resourceName: "Icon") ,iconInitialSize: CGSize(width: 70, height: 70), backgroundColor: UIColor(r: 248, g: 78, b: 0))
        
        self.view.addSubview(revealingSplashView)
        
        revealingSplashView.duration = 0.5
        
        revealingSplashView.animationType = SplashAnimationType.swingAndZoomOut
        
        revealingSplashView.startAnimation(){
            self.revealingLoaded = true
            self.setNeedsStatusBarAppearanceUpdate()
            print("Completed")
        }

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    private var revealingLoaded = false
    
    override var shouldAutorotate: Bool {
        return revealingLoaded
    }
    
    override var prefersStatusBarHidden: Bool {
        return !UIApplication.shared.isStatusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.fade
    }
    
}

class AllPermissionDataSource : SPRequestPermissionDialogInteractiveDataSource {
    
    override func headerTitle() -> String {
        return "Hello!"
    }
    
    override func headerSubtitle() -> String {
        return "Don't miss the Eclipse. We need your permission to use your location and notify you about Eclipse Events."
    }
    
    override func topAdviceTitle() -> String {
        return "Allow all permissions please. This helps to keep you informed with the Eclipse"
    }
    
    
}

extension TabViewController: SPRequestPermissionEventsDelegate {
    
    func didHide() {
        if  NotificationHelper.checkPermission() {
            NotificationHelper.appGrated = true
        } else  {
            print("Notifications Not Granted")
            NotificationHelper.appGrated = false
        }
        
        if  Location.checkPermission() {
            Location.appGrated = true
        } else  {
            print("Location Not Granted")
            Location.appGrated = false
        }
    }
    
    func didAllowPermission(permission: SPRequestPermissionType) {
        switch permission {
        case .notification:
            NotificationHelper.appGrated = true
            break
        case .locationWhenInUse :
            Location.appGrated = true
            break
        default:
            break
        }
    }
    
    func didDeniedPermission(permission: SPRequestPermissionType) {
        switch permission {
        case .notification:
            NotificationHelper.appGrated = false
            break
        case .locationWhenInUse :
            Location.appGrated = false
            break
        default:
            break
        }
    }
    
    func didSelectedPermission(permission: SPRequestPermissionType) {
        
    }
}

extension UITabBarController {
    
    func setTabBarVisible(visible:Bool, animated:Bool) {
        
        //* This cannot be called before viewDidLayoutSubviews(), because the frame is not set before this time
        
        // bail if the current state matches the desired state
        if tabBarIsVisible() == visible { return }
        
        // get a frame calculation ready
        let frame = self.tabBar.frame
        let height = frame.size.height
        let offsetY = (visible ? -height : height)
        
        // zero duration means no animation
        let duration:TimeInterval = (animated ? 0.3 : 0.0)
        
        //  animate the tabBar
        UIView.animate(withDuration: duration) {
            self.tabBar.frame = frame.offsetBy(dx: 0, dy: offsetY)
            return
        }
    }
    
    func tabBarIsVisible() -> Bool {
        return self.tabBar.frame.origin.y < view.frame.maxY
    }
}
