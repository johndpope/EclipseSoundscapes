//
//  PartnerCell.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 7/24/17.
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

import Eureka

struct Partner : Equatable {
    var name: String
    var website: String
    var bio : String
    var photo: UIImage?
    
    init(name: String, website: String, bio: String, photo: UIImage?) {
        self.name = name
        self.website = website
        self.bio = bio
        self.photo = photo
    }
}

func ==(lhs: Partner, rhs: Partner) -> Bool {
    return lhs.name == rhs.name
}

final class PartnerCell: Cell<Partner>, CellType {
    
    @IBOutlet weak var memberImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var websiteBtn: UIButton!
    
    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setup() {
        super.setup()
        selectionStyle = .none
        nameLabel.font = UIFont.getDefautlFont(.meduium, size: 17)
        websiteBtn.titleLabel?.font = UIFont.getDefautlFont(.condensedMedium, size: 14)
        websiteBtn.contentHorizontalAlignment = .left
        websiteBtn.addTarget(self, action: #selector(openWebsite), for: .touchUpInside)
        websiteBtn.isAccessibilityElement = false
        memberImageView.contentMode = .scaleAspectFit
        memberImageView.clipsToBounds = true
        height = { return UITableViewAutomaticDimension }
        
        self.accessibilityTraits = UIAccessibilityTraitLink | UIAccessibilityTraitHeader
    }
    
    override func update() {
        super.update()
        if let partner = row.value {
            nameLabel.text = partner.name
            websiteBtn.setTitle(partner.website, for: .normal)
            if let photo = partner.photo {
                memberImageView.image = photo
            }
            
            self.accessibilityLabel = partner.name
        }
    }
    
    override func accessibilityActivate() -> Bool {
        self.openWebsite()
        return true
    }
    
    func openWebsite() {
        guard let partner = row.value, let url = URL.init(string: partner.website) else {
            return
        }
        let alert = UIAlertController(title: "Open in Safari", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Sure", style: .default, handler: { _ in
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(url)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        let top = Utility.getTopViewController()
        top.present(alert, animated: true, completion: nil)
    }
}

final class PartnerRow: Row<PartnerCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<PartnerCell>(nibName: "PartnerCell")
    }
}
