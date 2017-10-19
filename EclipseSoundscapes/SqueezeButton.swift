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

extension UIButton {
    func addSqueeze() {
        self.addTarget(self, action: #selector(squeeze), for: [.touchDown, .touchDragInside])
        self.addTarget(self, action: #selector(unSqueeze), for: [.touchDragExit, .touchUpInside,.touchCancel])
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

extension  UINavigationItem  {
    func addSqeuuzeBackBtn(_ target : Any, action: Selector, for events: UIControlEvents) {
        let button = UIButton(type: .system)
        button.addSqueeze()
        button.setImage(#imageLiteral(resourceName: "left-small").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .black
        button.accessibilityLabel = "Back"
        button.addTarget(target, action: action, for: events)
        button.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        self.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
}
