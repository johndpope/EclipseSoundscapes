//
//  NoEclipseView.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 8/7/17.
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

class NoEclipseView : UIView {
    
    deinit {
        print("No Eclipse View Removed")
    }
    
    var titleLabel : UILabel = {
        var label = UILabel()
        label.text = "Unfortuntely there is no visible Eclipse at your location"
        label.textColor = .black
        label.accessibilityTraits = UIAccessibilityTraitHeader
        label.textAlignment = .center
        label.font = UIFont.getDefautlFont(.bold, size: 20)
        label.numberOfLines = 0
        return label
    }()
    
    var iconImageView : UIImageView = {
        var iv = UIImageView(image: #imageLiteral(resourceName: "EclipseSoundscapes-Eclipse"))
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .clear
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    lazy var locationBtn : UIButton = {
        var btn = UIButton(type: .system)
        btn.addSqueeze()
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle("Get Closest Location From Me", for: .normal)
        btn.setImage(#imageLiteral(resourceName: "location").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.accessibilityLabel = "Get Closest Location of Eclipse From Me"
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = Color.eclipseOrange
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(titleLabel)
        addSubview(locationBtn)
        addSubview(iconImageView)
        
        //Title Label
        titleLabel.anchorWithConstantsToTop(nil, left: leftAnchor, bottom: iconImageView.topAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0)
        
        iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 175).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: 175).isActive = true
        
        //Location Btn
        locationBtn.frame.size = CGSize(width: frame.width, height: 50)
        
        locationBtn.anchor(iconImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 10, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 50)
        
        locationBtn.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        locationBtn.layer.cornerRadius = locationBtn.frame.height/2
    }

    func setAction(_ target: Any, action: Selector) {
        
        locationBtn.addTarget(target, action: action, for: .touchUpInside)
    }
}
