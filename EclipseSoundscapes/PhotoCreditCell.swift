//
//  PhotoCreditCell.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 8/1/17.
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

struct PhotoCredit : Equatable {
    var name: String
    var website: String
    var makers: String
    var photo: UIImage?
    
    init(name: String, website: String, makers: String, photo: UIImage?) {
        self.name = name
        self.website = website
        self.makers = makers
        self.photo = photo
    }
}

func ==(lhs: PhotoCredit, rhs: PhotoCredit) -> Bool {
    return lhs.name == rhs.name
}

final class PhotoCreditCell: Cell<PhotoCredit>, CellType {
    
    @IBOutlet weak var photoImageView: UIImageView!
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
        nameLabel.font = UIFont.getDefautlFont(.meduium, size: 15)
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 0
        
        websiteBtn.titleLabel?.font = UIFont.getDefautlFont(.condensedMedium, size: 14)
        websiteBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        websiteBtn.contentHorizontalAlignment = .center
        websiteBtn.addTarget(self, action: #selector(openWebsite), for: .touchUpInside)
        
        websiteBtn.isAccessibilityElement = false
        photoImageView.contentMode = .scaleAspectFit
        photoImageView.clipsToBounds = true
        height = { return 125 }
        
        self.accessibilityTraits = UIAccessibilityTraitLink | UIAccessibilityTraitHeader
    }
    
    override func update() {
        super.update()
        if let credit = row.value {
            nameLabel.text = credit.name + "\n" + credit.makers
            websiteBtn.setTitle(credit.website, for: .normal)
            if let photo = credit.photo {
                photoImageView.image = photo
            }
            
            self.accessibilityLabel = credit.name
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
        alert.addAction(UIAlertAction(title: "Sure", style: .destructive, handler: { _ in
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

final class PhotoCreditRow: Row<PhotoCreditCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<PhotoCreditCell>(nibName: "PhotoCreditCell")
    }
}

