//
//  PermissionButton.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 8/28/17.
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
import Material

/// Track the press of the permission buttons
protocol PermissionButtonDelegate: class {
    
    /// Permission button was pressed
    ///
    /// - Parameter type: Associated permission type
    func didPressPermission(for type: PermissionType)
}

class PermissionButton : UIButton {
    
    weak var delegate : PermissionButtonDelegate?
    
    /// Associated permission type
    var permissionType: PermissionType! {
        didSet {
            initalize()
        }
    }
    
    /// Local Permission Manager
    private var permission : PermissionInterface!
    
    
    /// Key for writing and reading from UserDefaults
    private var key = ""
    
    /// Track presses
    private var didPress = false
    
    
    /// Track previous permission request
    private var didRequest = false
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    /// Setup Button
    func commonInit() {
        addSqueeze()
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        setTitleColor(.white, for: .normal)
        self.titleLabel?.font = UIFont.getDefautlFont(.bold, size: (titleLabel?.font.pointSize)!)
        addTarget(self, action: #selector(hanldeButtonTouch), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.cornerRadius = self.bounds.height/2
    }
    
    
    /// Initalize the button for its permission
    private func initalize() {
        
        switch permissionType! {
        case .notification:
            permission = NotificationPermission()
            
            setTitle("Notifications", for: .normal)
            setImage(#imageLiteral(resourceName: "notifications").withRenderingMode(.alwaysOriginal), for: .normal)
            accessibilityLabel = "Notification Permission"
            key = "Notification"
            break
        case .locationWhenInUse:
            permission = LocationPermission.init(type: .WhenInUse)
            
            setTitle("Location", for: .normal)
            setImage(#imageLiteral(resourceName: "location").withRenderingMode(.alwaysOriginal), for: .normal)
            accessibilityLabel = "Location Permission"
            key = "Location"
            break
        }
        
        let authorized = permission.isAuthorized()
        update(authorized)
    }
    
    
    /// Update button after authorization change
    private func update(_ authorized : Bool) {
        backgroundColor = authorized ? .white: Color.lead
        setTitleColor(authorized ? .black : .white, for: .normal)
        
        didRequest = UserDefaults.checkRequestPermission(forKey: key)
        if didRequest {
            accessibilityValue = authorized ? "Allowed" : "Denied"
        }
    }
    
    /// Setup and request Permission
    @objc private func hanldeButtonTouch() {
        
        if (didPress && !permission.isAuthorized()) || (didRequest && !permission.isAuthorized())  {
            handlePermissionRequest()
        } else {
            permission.request(withComlectionHandler: {[weak self] () -> ()? in
                if let key = self?.key {
                    UserDefaults.setRequestPermission(key, value: true)
                }
                return self?.handlePermissionRequest()
            })
        }
        
        didPress = true
    }
    
    
    /// Handle the update to the Permission Buttons after the permission has showed
    private func handlePermissionRequest(){
        
        let authorized = permission.isAuthorized()
        update(authorized)
        
        if permission is LocationPermission {
           handleLocationPermission(authorized)
        } else {
            NotificationHelper.appGrated = authorized
        }
        delegate?.didPressPermission(for: self.permissionType!)
    }
    
    
    
    /// Handle Location Permission
    ///
    /// - Parameter authorized: Status of Location permission
    private func handleLocationPermission(_ authorized: Bool) {
        if let locationPermission = permission as? LocationPermission {
            if !authorized {
                if !locationPermission.checkLocationServices() {
                    locationSettingsAlert {
                        UserDefaults.setRequestPermission(self.key, value: false)
                        self.didPress = false
                        self.didRequest = false
                    }
                } else {
                    settingAlert()
                }
            }
        }
        Location.appGrated = authorized
    }
    
    
    /// Show Alert that permission has been denied
    private func settingAlert() {
        let alertVC = UIAlertController(title: "\(key) permission has been denied", message: "Manage \(key) permission in Settings", preferredStyle: .alert)
        let settingAction = UIAlertAction(title: "Settings", style: .destructive, handler: { (_) in
            NotificationCenter.default.addObserver(self, selector: #selector(self.returnedToApplication), name: .UIApplicationDidBecomeActive, object: nil)
            Utility.settings()
        })
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (_) in
            alertVC.dismiss(animated: true, completion: nil)
        })
        
        alertVC.addAction(settingAction)
        alertVC.addAction(okayAction)
        
        Utility.getTopViewController().present(alertVC, animated: true, completion: nil)
    }
    
    /// Show Alert that permission has been denied
    ///
    /// - Parameter completion: Completion block to execute after user presses Settings action
    private func locationSettingsAlert(_ completion: @escaping (()->Void)) {
        let instructions = "1. Open the Seetings app\n2. Select Privacy\n3. Select Location Services\n4. Turn on Location Services"
        let alertVC = UIAlertController(title: "Location Services are disabled", message: instructions, preferredStyle: .alert)
        let settingAction = UIAlertAction(title: "Settings", style: .destructive, handler: { (_) in
            NotificationCenter.default.addObserver(self, selector: #selector(self.returnedToApplication), name: .UIApplicationDidBecomeActive, object: nil)
            completion()
            Utility.settings()
        })
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (_) in
            alertVC.dismiss(animated: true, completion: nil)
        })
        
        alertVC.addAction(settingAction)
        alertVC.addAction(okayAction)
        
        Utility.getTopViewController().present(alertVC, animated: true, completion: nil)
    }
    
    
    /// Notification handler for when returns from app settings
    @objc private func returnedToApplication() {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
//        handlePermissionRequest()
        hanldeButtonTouch()
    }

}

extension UserDefaults {
    
    class func setRequestPermission(_ key: String, value: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
    }
    
    class func checkRequestPermission(forKey key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
    
}
