//
//  Utility.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 6/6/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import UIKit

extension UIAlertController{
    class func appSettingsAlert(title: String, message: String)-> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) in
            UIApplication.shared.open(URL.init(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alert
    }
}
