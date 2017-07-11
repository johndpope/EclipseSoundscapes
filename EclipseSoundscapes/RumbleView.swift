//
//  RumbleView.swift
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

class RumbleMap : UIImageView {
    
    var isActive = false {
        didSet {
            self.accessibilityTraits ^= UIAccessibilityTraitAllowsDirectInteraction
            if isActive {
                accessibilityLabel = "Rumble Map Started"
            } else {
                accessibilityLabel = "Rumble Map Stopped"
            }
        }
    }
    
    override func accessibilityActivate() -> Bool {
        isActive = !isActive
        return true
    }
}
