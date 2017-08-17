//
//  RumbleMapImageView.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 7/5/17.
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

class RumbleMapImageView : UIImageView {
    
    init(){
        super.init(frame: .zero)
        isAccessibilityElement = true
        isUserInteractionEnabled = true
        backgroundColor = .black
        contentMode = .scaleAspectFit
        accessibilityTraits = UIAccessibilityTraitNone
        accessibilityLabel = "Rumble Map Inactive Double Tap to turn on"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var isActive = false {
        didSet {
            if isActive {
                self.accessibilityTraits |= UIAccessibilityTraitAllowsDirectInteraction
                print("Became Active")
                print(self.accessibilityTraits.description)
                accessibilityLabel = "Rumble Map Running, Double Tap to turn off"
            } else {
                self.accessibilityTraits = UIAccessibilityTraitNone
                print("Not Active")
                print(self.accessibilityTraits.description)
                accessibilityLabel = "Rumble Map Inactive, Double Tap to turn on"
            }
        }
    }
    
    override func accessibilityActivate() -> Bool {
        self.isActive = true
        return true
    }
    
    override func accessibilityElementDidLoseFocus() {
        target?()
    }
    
    var target : (()->Void)?
}
