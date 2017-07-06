//
//  RumbleView.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 7/5/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

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
