//
//  LogoView.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 7/9/17.
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
//open class LogoView: UIImageView {
//    
//    convenience init(frame: CGRect, image : UIImage) {
//        self.init(frame: frame)
//        self.image = image
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        self.backgroundColor = .white
//        self.image = #imageLiteral(resourceName: "Banner")
//        self.contentMode = .scaleAspectFill
//    }
//    
//    required public init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func show(animate: Bool) {
//        self.alpha = 0
//        self.layer.transform = CATransform3DMakeScale(0.9, 0.9, 0.9)
//        if animate {
//            UIView.animate(withDuration: 2.0, animations: {
//                self.alpha = 1
//            })
//            UIView.animate(withDuration: 1.0, animations: {
//                self.layer.transform = CATransform3DIdentity
//            })
//        }
//        else {
//            self.alpha = 1
//            self.layer.transform = CATransform3DIdentity
//        }
//    }
//}

class LogoView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

