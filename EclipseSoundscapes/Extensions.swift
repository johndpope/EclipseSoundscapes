//
//  Extensions.swift
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

extension UIFontDescriptor {
    
    @nonobjc static var fontSizeTable: [UIFontTextStyle : [UIContentSizeCategory : CGFloat]] = {
        return [
            .headline: [
                .accessibilityExtraExtraExtraLarge: 25,
                .accessibilityExtraExtraLarge: 25,
                .accessibilityExtraLarge: 25,
                .accessibilityLarge: 25,
                .accessibilityMedium: 25,
                .extraExtraExtraLarge: 25,
                .extraExtraLarge: 23,
                .extraLarge: 21,
                .large: 19,
                .medium: 18,
                .small: 17,
                .extraSmall: 16],
            .subheadline: [
                .accessibilityExtraExtraExtraLarge: 21,
                .accessibilityExtraExtraLarge: 21,
                .accessibilityExtraLarge: 21,
                .accessibilityLarge: 21,
                .accessibilityMedium: 21,
                .extraExtraExtraLarge: 21,
                .extraExtraLarge: 19,
                .extraLarge: 17,
                .large: 15,
                .medium: 14,
                .small: 13,
                .extraSmall: 12],
            .body: [
                .accessibilityExtraExtraExtraLarge: 53,
                .accessibilityExtraExtraLarge: 47,
                .accessibilityExtraLarge: 40,
                .accessibilityLarge: 33,
                .accessibilityMedium: 28,
                .extraExtraExtraLarge: 23,
                .extraExtraLarge: 21,
                .extraLarge: 19,
                .large: 17,
                .medium: 16,
                .small: 15,
                .extraSmall: 14],
            .caption1: [
                .accessibilityExtraExtraExtraLarge: 18,
                .accessibilityExtraExtraLarge: 18,
                .accessibilityExtraLarge: 18,
                .accessibilityLarge: 18,
                .accessibilityMedium: 18,
                .extraExtraExtraLarge: 18,
                .extraExtraLarge: 16,
                .extraLarge: 14,
                .large: 12,
                .medium: 11,
                .small: 11,
                .extraSmall: 11],
            .caption2: [
                .accessibilityExtraExtraExtraLarge: 17,
                .accessibilityExtraExtraLarge: 17,
                .accessibilityExtraLarge: 17,
                .accessibilityLarge: 17,
                .accessibilityMedium: 17,
                .extraExtraExtraLarge: 17,
                .extraExtraLarge: 15,
                .extraLarge: 13,
                .large: 11,
                .medium: 11,
                .small: 11,
                .extraSmall: 11],
            .footnote: [
                .accessibilityExtraExtraExtraLarge: 19,
                .accessibilityExtraExtraLarge: 19,
                .accessibilityExtraLarge: 19,
                .accessibilityLarge: 19,
                .accessibilityMedium: 19,
                .extraExtraExtraLarge: 19,
                .extraExtraLarge: 17,
                .extraLarge: 15,
                .large: 13,
                .medium: 12,
                .small: 12,
                .extraSmall: 12]
            ]
    }()
    
    class func currentPreferredSize(textStyle: UIFontTextStyle = .body, scale: CGFloat = 1.0) -> CGFloat {
        let contentSize = UIApplication.shared.preferredContentSizeCategory
        guard let style = fontSizeTable[textStyle], let fontSize = style[contentSize] else { return 17 }
        return fontSize * scale
    }
    
    class func preferredFontDescriptor(fontName: Futura = .condensedMedium, textStyle: UIFontTextStyle = .body, scale: CGFloat = 1.0) -> UIFontDescriptor {
        var name : String!
        switch fontName {
        case .condensedMedium:
            name = "Futura-CondensedMedium"
            break
        case .extraBold:
            name = "Futura-CondensedExtraBold"
            break
        case .meduium :
            name = "Futura-Medium"
            break
        case .italic:
            name = "Futura-MediumItalic"
            break
        case .bold :
            if #available(iOS 10.0, *) {
                name = "Futura-Bold"
            } else {
                name = "Futura-CondensedMedium"
            }
            break
        }

        return UIFontDescriptor(name: name, size: currentPreferredSize(textStyle: textStyle, scale: scale))
    }
}

enum Futura {
    case condensedMedium
    case extraBold
    case meduium
    case italic
    case bold
}

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

extension UIButton {
    
}

extension UIColor {
    convenience init(r: Int, g: Int, b: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: a
        )
    }
    convenience init(hex: String, alpha: CGFloat) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
    
}


extension UIFont {
    
    /// Generate the system wide font.
    ///
    /// - Parameters:
    ///   - isBold: Should the text be bold.
    ///   - size: Font size
    /// - Returns: UIFont
    static func getDefautlFont(_ style : Futura, size: CGFloat) -> UIFont {
        
        var name : String!
        
        switch style {
        case .condensedMedium:
            name = "Futura-CondensedMedium"
            break
        case .extraBold:
            name = "Futura-CondensedExtraBold"
            break
        case .meduium :
            name = "Futura-Medium"
            break
        case .italic:
            name = "Futura-MediumItalic"
            break
        case .bold :
            if #available(iOS 10.0, *) {
                name = "Futura-Bold"
            } else {
                name = "Futura-CondensedMedium"
            }
            break
        }
        
        return UIFont.init(name: name, size: size)!
    }
    
}
