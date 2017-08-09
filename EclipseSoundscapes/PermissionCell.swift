//
//  PermissionCell
//  audible
//
//  Created by Arlindo Goncalves on 7/30/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//

import UIKit

protocol PermissionCellDelegate: class {
    func didFinish()
}


class PermissionCell: UICollectionViewCell {
    
    weak var collectionView: WalkthroughViewController?
    weak var delegate: PermissionCellDelegate?
    
    var didPressLocation = false
    var didPressNotification = false
    
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
    
    lazy var notificationBtn : SqueezeButton = {
        var btn = SqueezeButton(type: .system)
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle("Notifications", for: .normal)
        btn.setImage(#imageLiteral(resourceName: "notifications").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(notificationPermission(sender:)), for: .touchUpInside)
        btn.accessibilityLabel = "Notification Permission"
        return btn
    }()
    
    lazy var locationBtn : SqueezeButton = {
        var btn = SqueezeButton(type: .system)
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle("Location", for: .normal)
        btn.setImage(#imageLiteral(resourceName: "location").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(locationPermission(sender:)), for: .touchUpInside)
        btn.accessibilityLabel = "Location Permission"
        return btn
    }()
    
    lazy var laterBtn : SqueezeButton = {
        var btn = SqueezeButton(type: .system)
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle("Ask Later", for: .normal)
        btn.addTarget(self, action: #selector(later), for: .touchUpInside)
        btn.accessibilityHint = "Closes the Walk Through. Will ask for permission later in the app."
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.init(r: 227, g: 94, b: 5)
        setupViews()
    }
    
    func setupViews() {
        addSubview(titleLabel)
        addSubview(locationBtn)
        addSubview(notificationBtn)
        addSubview(iconImageView)
        addSubview(laterBtn)
        
        //Title Label
        titleLabel.anchorWithConstantsToTop(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        
        iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -50).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 175).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: 175).isActive = true
        
        //Location Btn
        locationBtn.frame.size = CGSize(width: frame.width, height: 50)
        
        locationBtn.anchor(iconImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 10, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 50)
        
        locationBtn.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        locationBtn.layer.cornerRadius = locationBtn.frame.height/2
        
        // Notification Btn
        notificationBtn.frame.size = CGSize(width: frame.width, height: 50)
        
        notificationBtn.anchor(locationBtn.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 5, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 50)
        
        notificationBtn.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        notificationBtn.layer.cornerRadius = notificationBtn.frame.height/2
        
        //later Btn
        laterBtn.frame.size = CGSize(width: frame.width/2, height: 30)
        
        laterBtn.anchor(nil, left: nil, bottom: bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 2, rightConstant: 0, widthConstant: frame.width/2, heightConstant: 30)
        
        laterBtn.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        laterBtn.layer.cornerRadius = laterBtn.frame.height/2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func locationPermission(sender: SqueezeButton) {
        let permission = SPLocationPermission.init(type: .WhenInUse)
        permission.request { () -> ()? in
            
            return self.handleButtonTouch(sender: sender, permission: permission)
        }
    }
    
    func notificationPermission(sender: SqueezeButton) {
        let permission = SPNotificationPermission.init()
        permission.request { () -> ()? in
            return self.handleButtonTouch(sender: sender, permission: permission)
        }
    }
    
    func handleButtonTouch(sender: SqueezeButton, permission: SPPermissionInterface){
        
        if permission is SPLocationPermission {
            if permission.isAuthorized() {
                Location.appGrated = true
                sender.accessibilityValue = "Allowed"
            } else {
                Location.appGrated = false
                sender.accessibilityValue = "Denied"
            }
            Location.appGrated = permission.isAuthorized()
            didPressLocation = true
        } else {
            if permission.isAuthorized() {
                NotificationHelper.appGrated = true
                sender.accessibilityValue = "Allowed"
            } else {
                NotificationHelper.appGrated = false
                sender.accessibilityValue = "Denied"
            }
            didPressNotification = true
        }
        
        sender.backgroundColor = .white
        sender.setTitleColor(.black, for: .normal)
        
        if didPressLocation && didPressNotification {
            later()
        }
    }
    
    func later() {
        delegate?.didFinish()
    }
    
    
}
