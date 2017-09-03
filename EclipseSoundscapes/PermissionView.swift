//
//  PermissionView.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 8/26/17.
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

/// Inform the permission's have been accepted or skipped
protocol PermissionViewDelegate: class {
    
    /// Send notice that permission view has finished
    func didFinish()
}


class PermissionView: UIView {
    
    weak var delegate: PermissionViewDelegate?
    
    /// Tracker for Location Permission button touch
    fileprivate var didPressLocation = false
    
    /// Tracker for Notification Permission button touch
    fileprivate var didPressNotification = false
    
    
    /// Permissions to handle
    var permissions : [PermissionType]!
    
    
    /// Count of permissions in order to track if all permissions have been handled
    fileprivate var count = 0
    
    var titleLabel : UILabel = {
        var label = UILabel()
        label.text = "Please Allow Access"
        label.accessibilityLabel = "Please Allow Access to the permissions below"
        label.textColor = .black
        label.accessibilityTraits = UIAccessibilityTraitHeader
        label.textAlignment = .center
        label.font = UIFont.getDefautlFont(.bold, size: 20)
        return label
    }()
    
    var iconImageView : UIImageView = {
        var iv = UIImageView(image: #imageLiteral(resourceName: "EclipseSoundscapes-Eclipse"))
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .clear
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    var laterLabel : UILabel = {
        var label = UILabel()
        label.text = "You can manage permissions in settings"
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.getDefautlFont(.condensedMedium, size: 14)
        return label
    }()
    
    
    lazy var laterBtn : UIButton = {
        var btn = UIButton(type: .system)
        btn.addSqueeze()
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        btn.titleLabel?.font = UIFont.getDefautlFont(.bold, size: (btn.titleLabel?.font.pointSize)!)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle("Ask Later", for: .normal)
        btn.addTarget(self, action: #selector(later), for: .touchUpInside)
        btn.accessibilityHint = "Closes the Walk Through. Will ask for permission later in the app."
        return btn
    }()
    
    var stackView: UIStackView = {
        var sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.alignment = .fill
        sv.distribution = .fillProportionally
        sv.axis = .vertical
        sv.spacing = 10
        return sv
    }()
    
    required init(for permissions: [PermissionType]) {
        super.init(frame: .zero)
        self.count = permissions.count
        self.permissions = permissions
        backgroundColor = UIColor.init(r: 227, g: 94, b: 5)
        setupViews()
    }
    
    /// Setup and layout view's subviews
    func setupViews() {
        addSubview(titleLabel)
        addSubview(iconImageView)
        addSubview(stackView)
        addSubview(laterLabel)
        addSubview(laterBtn)
        // Title Label
        titleLabel.anchorWithConstantsToTop(topAnchor, left: leftAnchor, bottom: iconImageView.topAnchor, right: rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 20, rightConstant: 0)
        
        // ImageView
        iconImageView.setSize(175, height: 175)
        iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        // StackView - Contains the Permission Buttons
        stackView.anchor(nil, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 20, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        stackView.center(in: self)
        
        // Stack buttons
        for permission in permissions {
            let permissionBtn = PermissionButton(type: .system)
            permissionBtn.permissionType = permission
            permissionBtn.setSize(stackView.width, height: 50)
            permissionBtn.delegate = self
            stackView.addArrangedSubview(permissionBtn)
        }
        
        // Later Label
        laterLabel.anchor(nil, left: leftAnchor, bottom: laterBtn.topAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 0, heightConstant: 30)
        
        // Later Button
        laterBtn.setSize(100, height: 30)
        laterBtn.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        laterBtn.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        laterBtn.cornerRadius = laterBtn.bounds.height/2
    }
    
    /// Tell the delegate that permission cell's job has been completed
    func later() {
        delegate?.didFinish()
    }
}

extension PermissionView: PermissionButtonDelegate {
    func didPressPermission(for type: PermissionType) {
        switch type {
        case .notification:
            if didPressNotification == false {
                count -= 1
                didPressNotification = true
            }
            break
        case .locationWhenInUse:
            if didPressLocation == false {
                count -= 1
                didPressLocation = true
            }
            break
        }

        if self.count == 0 {
            delegate?.didFinish()
        }
    }
}
