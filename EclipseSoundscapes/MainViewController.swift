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

class MainViewController: SelectionBarTabBarController {
    
    let eclipseCenterVC : EclipseViewController = {
        let vc = EclipseViewController()
        let tabItem = UITabBarItem(title: "Eclipse Center", image: #imageLiteral(resourceName: "events_icon").withRenderingMode(UIImageRenderingMode.alwaysTemplate), tag: 0)
        tabItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.getDefautlFont(.meduium, size: 10)], for: .normal)
        vc.tabBarItem = tabItem
        return vc
    }()
    
    let rumbleMapVC : RumbleMapViewController = {
        let vc = RumbleMapViewController()
        let tabItem = UITabBarItem(title: "Eclipse Features", image: #imageLiteral(resourceName: "rumbleTouch").withRenderingMode(UIImageRenderingMode.alwaysTemplate), tag: 0)
        tabItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.getDefautlFont(.meduium, size: 10)], for: .normal)
        vc.tabBarItem = tabItem
        return vc
    }()
    
    let mediaCenterVC : MediaCenterViewController = {
        let vc = MediaCenterViewController()
        let tabItem = UITabBarItem(title: "Media", image: #imageLiteral(resourceName: "play-main").withRenderingMode(UIImageRenderingMode.alwaysTemplate), tag: 0)
        tabItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.getDefautlFont(.meduium, size: 10)], for: .normal)
        vc.tabBarItem = tabItem
        return vc
    }()
    
    let aboutVC : AboutViewController = {
        let vc = AboutViewController()
        let tabItem = UITabBarItem(title: "About", image: #imageLiteral(resourceName: "More").withRenderingMode(UIImageRenderingMode.alwaysTemplate), tag: 0)
        tabItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.getDefautlFont(.meduium, size: 10)], for: .normal)
        vc.tabBarItem = tabItem
        return vc
    }()
    
    override func viewDidLoad() {
        viewControllers = [eclipseCenterVC, rumbleMapVC, mediaCenterVC, aboutVC]
        super.viewDidLoad()
    
        self.tabBar.barTintColor = Color.lead
        self.tabBar.tintColor = Color.eclipseOrange
        self.tabBar.isOpaque = false
        self.tabBar.isTranslucent = false
        
        if Location.isGranted {
            LocationManager.getLocation()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

class SelectionBarTabBarController : UITabBarController {
    
    let selectionBar : UIView = {
        var view = UIView()
        view.backgroundColor = Color.eclipseOrange
        return view
    }()
    
    var viewsInTab = Dictionary<Int, UIView?>()
    
    var selectionBarConstraint : NSLayoutConstraint!
    var selectionWidth : CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    func setupTabBar() {
        
        let firstTabButton = viewInTabAtIndex(index: 0)
        
        selectionWidth = firstTabButton.frame.width
        
        self.tabBar.addSubviews(selectionBar)
        selectionBar.anchor(tabBar.topAnchor)
        selectionBarConstraint = selectionBar.centerXAnchor.constraint(equalTo: firstTabButton.centerXAnchor)
        selectionBarConstraint.isActive = true
        selectionBar.heightAnchor.constraint(equalToConstant: 3).isActive = true
        selectionBar.widthAnchor.constraint(equalToConstant: selectionWidth).isActive = true
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let items = self.tabBar.items {
            for (index, currentItem) in items.enumerated() {
                if currentItem == item {
                    moveSelectionBar(toIndex: index)
                }
            }
        }
    }
    
    private func moveSelectionBar(toIndex index: Int,animated:Bool = true){
        
        if selectionBarConstraint == nil{
            return
        }
        
        let currentTab = viewInTabAtIndex(index: index)
        
        selectionBarConstraint.isActive = false
        let animations = {() -> Void in
            self.selectionBarConstraint = self.selectionBar.centerXAnchor.constraint(equalTo: currentTab.centerXAnchor)
            self.selectionBarConstraint.isActive = true
            self.tabBar.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: animations, completion: { _ in })
        }
        else {
            animations()
        }
    }
    
    private func viewInTabAtIndex(index: Int) -> UIView {
        if let tabView = viewsInTab[index] as? UIView {
            return tabView
        }
        var subviews = tabBar.subviews.flatMap { (view:UIView) -> UIView? in
            if let view = view as? UIControl {
                return view
            }
            return nil
        }
        subviews.sort { $0.frame.origin.x < $1.frame.origin.x }
        if subviews.count > index {
            viewsInTab.updateValue(subviews[index], forKey: index)
            return subviews[index]
        }
        viewsInTab.updateValue(subviews.last, forKey: index)
        return subviews.last ?? UIView()
    }
    
    
    
}
