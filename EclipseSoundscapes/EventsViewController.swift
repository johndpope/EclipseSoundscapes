//
//  EventsViewController.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 6/21/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import UIKit

class EventsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        AudioManager.registerEclipseNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
