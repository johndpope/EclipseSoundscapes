//
//  TabViewController.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 6/12/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import UIKit
import CoreLocation

class TabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        signIn()
        
        self.tabBar.barTintColor = UIColor.init(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0)
        self.tabBar.tintColor = UIColor.init(red: 214/255, green: 93/255, blue: 18/255, alpha: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        getLocation()
    }
    
    func signIn() {
        Authenticator.auth.signIn(withEmail: "Username", password: "Password") { (_, error) in
            guard error == nil else {
                let alert = UIAlertController(title: "We couldn't Sign You in", message: "\(error?.localizedDescription ?? "")", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { (_) in
                    self.signIn()
                }))
                alert.addAction(UIAlertAction(title: "Not Now", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
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
