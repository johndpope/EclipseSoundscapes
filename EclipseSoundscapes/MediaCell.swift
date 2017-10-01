//
//  MediaCell.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 8/3/17.
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

class MediaCell : UITableViewCell {
    
    var media: Media? {
        didSet {
            if let media = media {
                self.load(media)
            }
        }
    }
    
    var eventImageView : UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        return iv
    }()
    
    var titleLabel : UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.getDefautlFont(.meduium, size: 20)
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCell()
    }
    
    
    func setupCell() {
        self.accessoryType = .disclosureIndicator
        
        self.addSubview(eventImageView)
        self.addSubview(titleLabel)
        
        eventImageView.anchorWithConstantsToTop(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 8, leftConstant: 8, bottomConstant: 8, rightConstant: 0)
        eventImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        eventImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: eventImageView.rightAnchor, constant: 16).isActive = true
        
        if let accessoryView = self.accessoryView {
            titleLabel.rightAnchor.constraint(equalTo: accessoryView.leftAnchor, constant: 2).isActive = true
        }
    }
    
    func load(_ media: Media) {
        self.eventImageView.image = media.image
        self.titleLabel.text = media.name
    }
    
}
