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
import BRYXBanner

class TabViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customizeTabBar()
        registerEclipseNotifications()
        
        if Location.isGranted {
            LocationManager.getLocation()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func customizeTabBar() {
        self.tabBar.barTintColor = UIColor.init(r: 33, g: 33, b: 33)
        self.tabBar.tintColor = UIColor.init(r: 227, g: 94, b: 5) // Foreground/Background Ratio 4.50053
        self.tabBar.isOpaque = false
        self.tabBar.isTranslucent = false
        
        let width : CGFloat = 50.0
        let height = self.tabBar.frame.height
        
        self.tabBar.selectionIndicatorImage = UIImage.selectionIndiciatorImage(color: UIColor.init(r: 227, g: 94, b: 5), size: CGSize.init(width: width, height: height), lineWidth: 2.0)
        
        for item in self.tabBar.items! {
            item.accessibilityTraits = UIAccessibilityTraitButton
            
        }
        
        self.tabBar.items?[0].accessibilityLabel = "My Eclipse Center"
    }
    
    func registerEclipseNotifications() {
        
        var reminders : Reminder = .allDone
        if !UserDefaults.standard.bool(forKey: "Contact1Reminder") {
            reminders.insert(.firstReminder)
        }
        if !UserDefaults.standard.bool(forKey: "Contact1Done") {
            reminders.insert(.contact1)
        }
        if !UserDefaults.standard.bool(forKey: "TotalityReminder") {
            reminders.insert(.totaltyReminder)
        }
        if !UserDefaults.standard.bool(forKey: "TotalityDone") {
            reminders.insert(.totality)
            
        }
        
        NotificationHelper.addObserver(self, reminders: reminders, selector: #selector(catchEclipseNotification(notification:)))
    }
    
    @objc func catchEclipseNotification(notification: Notification){
        switch notification.name {
        case Notification.Name.EclipseFirstReminder:
            
            print("1!")
            NotificationHelper.removeObserver(self, reminders: .firstReminder)
            showReminderBanner(message: "The Solar Eclipse is going to being soon.")
            
        case Notification.Name.EclipseContact1:
            
            print("2!")
            NotificationHelper.removeObserver(self, reminders: .contact1)
            
            let media = Media.init(name: "First Contact", resourceName: "First_Contact_Short", infoRecourceName: "First Contact-Short" ,mediaType: FileType.mp3, image: #imageLiteral(resourceName: "First Contact"))
            openPlayer(with: media)
            break
            
        case Notification.Name.EclipseTotalityReminder:
            print("3!")
            NotificationHelper.removeObserver(self, reminders: .totaltyReminder)
            
            showReminderBanner(message: "The Total Solar Eclipse is going to being soon.")
            break
            
        case Notification.Name.EclipseTotality:
            print("4!")
            NotificationHelper.removeObserver(self, reminders: .totality)
            
            let full = RealtimeEvent(name: "Totality Experience", resourceName: "Realtime_Eclipse_Shorts", mediaType: FileType.mp3, image: #imageLiteral(resourceName: "Totality"), media:
                RealtimeMedia(name: "Baily's Beads", infoRecourceName: "Baily's Beads-Short", image: #imageLiteral(resourceName: "Baily's Beads"), startTime: 0, endTime: 24),
                RealtimeMedia(name: "Totality", infoRecourceName: "Totality-Short", image: #imageLiteral(resourceName: "Totality"), startTime: 120, endTime: 145),
                RealtimeMedia(name: "Diamond Ring", infoRecourceName: "Diamond Ring-Short", image: #imageLiteral(resourceName: "Diamond Ring"), startTime: 200, endTime: 213),
                RealtimeMedia(name: "Sun as a Star", infoRecourceName: "Sun as a Star", image: #imageLiteral(resourceName: "Sun as a Star"), startTime: 320, endTime: 356))
            
            openPlayer(with: full)
            break
            
        case Notification.Name.EclipseAllDone:
            print("Eclipse All Done")
            break
        default:
            break
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
    var banner : Banner?
    var countdown = 10
    var timer : Timer?
    func openPlayer(with media: Media) {
        let title = "Eclipse Media Player is about to open in \(countdown) seconds"
        let detail = "Get Ready to listen."
        
        banner = Banner(title: title, subtitle: detail, image: #imageLiteral(resourceName: "EclipseSoundscapes-Eclipse"), backgroundColor: Color.eclipseOrange)
        banner?.titleLabel.textColor = .black
        
        banner?.detailLabel.textColor = .black
        banner?.dismissesOnTap = false
        banner?.dismissesOnSwipe = false
        
        banner?.didDismissBlock = {
            self.timer?.invalidate()
            self.timer = nil
            self.countdown = 10
            let playbackVc = PlaybackViewController()
            playbackVc.media = media
            playbackVc.isRealtimeEvent = true
            Utility.getTopViewController().present(playbackVc, animated: true, completion: nil)
        }
        
        banner?.isAccessibilityElement = true
        banner?.accessibilityElementsHidden = true
        banner?.accessibilityLabel = title + detail
        
        banner?.show(duration: 10.0)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimeforBanner), userInfo: nil, repeats: true)
        
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, banner)
    }
    
    @objc func updateTimeforBanner() {
        if countdown > 0 {
            countdown -= 1
        }
        self.banner?.titleLabel.text = "Eclipse Media Player is about to open in \(countdown) seconds"
        banner?.accessibilityLabel = "\(self.banner?.titleLabel.text ?? "") \(self.banner?.detailLabel.text ?? "")"
    }
    
    
    func showReminderBanner(message: String) {
        banner = Banner(title: message, subtitle: "", image: #imageLiteral(resourceName: "EclipseSoundscapes-Eclipse"), backgroundColor: Color.eclipseOrange)
        banner?.titleLabel.textColor = .black
        banner?.detailLabel.textColor = .black
        
        banner?.isAccessibilityElement = true
        banner?.accessibilityElementsHidden = true
        banner?.accessibilityLabel = title
        
        banner?.show(duration: 5.0)
        
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, banner)
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
