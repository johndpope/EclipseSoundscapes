//
//  DynamicLabel.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 9/1/17.
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

class DynamicLabel : UILabel {
    
    var fontName: Futura = .condensedMedium
    var textStyle: UIFontTextStyle = .body
    var scale : CGFloat = 1.0
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    init(frame: CGRect = .zero, fontName: Futura = .condensedMedium, textStyle: UIFontTextStyle = .body, scale : CGFloat = 1.0){
        super.init(frame: frame)
        self.fontName = fontName
        self.textStyle = textStyle
        self.scale = scale
        commonInit()
    }
    
    func commonInit() {
        self.numberOfLines = 0
        self.adjustsFontSizeToFitWidth = true
        self.lineBreakMode = .byWordWrapping
        setDynamicSize()
        NotificationCenter.default.addObserver(self, selector: #selector(setDynamicSize), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    func setDynamicSize() {
        self.font = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(fontName: self.fontName, textStyle: self.textStyle, scale: self.scale), size: 0)
        superview?.layoutIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
}
