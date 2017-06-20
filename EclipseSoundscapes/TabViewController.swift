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
    
    var locator : Locator?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        signIn()
        
        locator = Locator()
        locator?.delegate = self
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
    
    func getLocation() {
        locator?.getLocation()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}
extension TabViewController : LocatorDelegate {
    func presentFailureAlert(_ alert : UIViewController) {
        self.present(alert, animated: true, completion: nil)
    }
    
    func locator(didUpdateBestLocation location: CLLocation) {
        UserDefaults.standard.set(location.coordinate.longitude, forKey: "Longitude")
        UserDefaults.standard.set(location.coordinate.latitude, forKey: "Latitude")
    }
    
    func locator(didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
