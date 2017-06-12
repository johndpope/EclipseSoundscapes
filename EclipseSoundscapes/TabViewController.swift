//
//  TabViewController.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 6/12/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        signIn()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
}
