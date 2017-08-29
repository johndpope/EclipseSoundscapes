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
import BRYXBanner

protocol PermissionButtonDelegate: class {
    func didPressPermission(for type: PermissionType)
}

class PermissionButton : UIButton {
    
    weak var delegate : PermissionButtonDelegate?
    
    var permissionType: PermissionType? {
        didSet {
            initalize()
        }
    }
    
    private var permission : PermissionInterface!
    private var didPress = false
    private var didRequest = false
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
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
    
    func initalize() {
        
        guard let type = self.permissionType else {
            return
        }
        
        switch type {
        case .notification:
            permission = NotificationPermission()
            
            setTitle("Notifications", for: .normal)
            setImage(#imageLiteral(resourceName: "notifications").withRenderingMode(.alwaysOriginal), for: .normal)
            accessibilityLabel = "Notification Permission"
            break
        case .locationWhenInUse:
            permission = LocationPermission.init(type: .WhenInUse)
            
            setTitle("Location", for: .normal)
            setImage(#imageLiteral(resourceName: "location").withRenderingMode(.alwaysOriginal), for: .normal)
            accessibilityLabel = "Location Permission"
            break
        default:
            return
        }
        
        let authorized = permission.isAuthorized()
        backgroundColor = authorized ? .white: Color.lead
        setTitleColor(authorized ? .black : .white, for: .normal)
        
        didRequest = UserDefaults.standard.bool(forKey: "Permission\(type.rawValue)")
        if didRequest {
            accessibilityValue = authorized ? "Allowed" : "Denied"
        }
    }
    
    /// Setup and request Permission
    func hanldeButtonTouch() {
        guard let type = self.permissionType else {
            return
        }
        
        if didPress {
            if !permission.isAuthorized() {
                settingAlert()
            }
        } else {
            if !didRequest {
                permission.request { () -> ()? in
                    self.didRequest = true
                    UserDefaults.standard.set(true, forKey: "Permission\(type.rawValue)")
                    return self.handlePermissionRequest()
                }
            } else {
                if !permission.isAuthorized() {
                    settingAlert()
                }
            }
        }
        
        didPress = true
    }
    
    
    /// Handle the update to the Permission Buttons after the permission has showed
    func handlePermissionRequest(){
        
        let authorized = self.permission.isAuthorized()
        backgroundColor = authorized ? .white: Color.lead
        setTitleColor(authorized ? .black : .white, for: .normal)
        accessibilityValue = authorized ? "Allowed" : "Denied"
        
        if permission is LocationPermission {
            if authorized {
                Location.appGrated = true
            } else {
                Location.appGrated = false
            }
            Location.appGrated = authorized
        } else {
            if authorized {
                NotificationHelper.appGrated = true
            } else {
                NotificationHelper.appGrated = false
            }
        }
        delegate?.didPressPermission(for: self.permissionType!)
    }
    
    private func update() {
        let authorized = permission.isAuthorized()
        backgroundColor = authorized ? .white: Color.lead
        setTitleColor(authorized ? .black : .white, for: .normal)
    }
    
    /// Show Alert that permission has been denied
    private func settingAlert() {
        let alertVC = UIAlertController(title: "Important", message: "Permission has been denied", preferredStyle: .alert)
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
    
    func returnedToApplication() {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
        handlePermissionRequest()
    }
    
    
    
}
