//
//  SqueezeButton.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 7/30/17.
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

class SqueezeButton : UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(squeeze), for: [.touchDown, .touchDragInside])
        self.addTarget(self, action: #selector(unSqueeze), for: [.touchDragExit])
        self.addTarget(self, action: #selector(unSqueeze), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func squeeze() {
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform.init(scaleX: 0.9, y: 0.9)
        }
    }
    
    @objc private func unSqueeze() {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
        }) { (_) in
            UIView.animate(withDuration: 0.1, animations: {
                self.transform = .identity
            })
        }
        
    }
    
}
