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
import Material

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

extension UIColor {
    
    /// Convience constructor for UIColor
    /// - Note: Values are out of 0-255
    /// - Parameters:
    ///   - r: red
    ///   - g: green
    ///   - b: blue
    ///   - a: alpha
    convenience init(r: Int, g: Int, b: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: a
        )
    }
}

extension UIView {
    
    /// Add subviews
    /// - Note: Each view's translatesAutoresizingMaskIntoConstraints attribute is marked as false
    ///
    /// - Parameter views: Views to add
    func addSubviews(_ views : UIView...) {
        views.forEach { (view) in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
        }
    }
    
    
    /// Center a view in given view
    ///
    /// - Parameter view: View to center in
    /// - Returns: Array of NSLayoutContraints
    @discardableResult
    func center(in view : UIView) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchors = [NSLayoutConstraint]()
        anchors.append(centerXAnchor.constraint(equalTo: view.centerXAnchor))
        anchors.append(centerYAnchor.constraint(equalTo: view.centerYAnchor))
        anchors.forEach({$0.isActive = true})
        
        return anchors
    }
    
    
    /// Set the size of the view
    /// - Note: Values are constant values
    ///
    /// - Parameters:
    ///   - width: Width Constant
    ///   - height: Height Constant
    /// - Returns: Array of NSLayoutContraints
    @discardableResult
    func setSize(_ width: CGFloat, height: CGFloat ) -> [NSLayoutConstraint]{
        return self.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: width, heightConstant: height)
    }
    
    
    /// Set the size of the view
    /// - Note: Values are constrained to layout dimensions
    ///
    /// - Parameters:
    ///   - widthAnchor: Width dimension
    ///   - heightAnchor: Height dimension
    /// - Returns: Array of NSLayoutContraints
    @discardableResult
    func setSize(widthAnchor: NSLayoutDimension, heightAnchor: NSLayoutDimension) -> [NSLayoutConstraint]{
        var anchors =  [NSLayoutConstraint]()
        
        anchors.append(widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1))
        anchors.append(heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1))
        
        anchors.forEach({$0.isActive = true})
        return anchors
    }
    
    
    func anchorToTop(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil) {
        
        anchorWithConstantsToTop(top, left: left, bottom: bottom, right: right, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
    }
    
    func anchorWithConstantsToTop(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0) {
        
        _ = anchor(top, left: left, bottom: bottom, right: right, topConstant: topConstant, leftConstant: leftConstant, bottomConstant: bottomConstant, rightConstant: rightConstant)
    }
    
    @discardableResult
    func anchor(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0, widthConstant: CGFloat = 0, heightConstant: CGFloat = 0) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchors = [NSLayoutConstraint]()
        
        if let top = top {
            anchors.append(topAnchor.constraint(equalTo: top, constant: topConstant))
        }
        
        if let left = left {
            anchors.append(leftAnchor.constraint(equalTo: left, constant: leftConstant))
        }
        
        if let bottom = bottom {
            anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant))
        }
        
        if let right = right {
            anchors.append(rightAnchor.constraint(equalTo: right, constant: -rightConstant))
        }
        
        if widthConstant > 0 {
            anchors.append(widthAnchor.constraint(equalToConstant: widthConstant))
        }
        
        if heightConstant > 0 {
            anchors.append(heightAnchor.constraint(equalToConstant: heightConstant))
        }
        
        anchors.forEach({$0.isActive = true})
        
        return anchors
    }
        
        /// Get Rombus Pattern View
        ///
        /// - Returns: Rombus Pattern View
        class func rombusPattern() -> UIView {
            let iv = UIImageView()
            iv.image = #imageLiteral(resourceName: "Rhombus Pattern")
            return iv
        }
}


extension UIFont {
    
    /// Generate the system wide font.
    ///
    /// - Parameters:
    ///   - style: Futura Font style
    ///   - size: Font point size
    /// - Returns: Futura UIFont instance
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



extension UIImage {
    
    
    /// Construct selection indicator image
    ///
    /// - Parameters:
    ///   - color: Color of indicator
    ///   - size: Size of inidicator
    ///   - lineWidth: Inidicator width
    ///   - position: Position of line in the image
    /// - Returns: Selection indicator image
    class func selectionIndiciatorImage(color : UIColor, size: CGSize, lineWidth: CGFloat, position : ScreenPosition = .top) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect.init(x: 0, y: position == .top ? 0 : size.height - lineWidth, width: size.width, height: lineWidth))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    
    /// Resizes image to the given size
    /// - Author: Karthick Selvaraj [link](https://stackoverflow.com/questions/42545955/scale-image-to-smaller-size-in-swift3)
    ///
    /// - Parameter size: Size to resize to
    /// - Returns: Newly resized  UIImage
    func resizeImage(to size: CGSize) -> UIImage {
        
        var actualHeight: CGFloat = self.size.height
        var actualWidth: CGFloat = self.size.width
        let maxHeight: CGFloat = size.width
        let maxWidth: CGFloat = size.height
        var imgRatio: CGFloat = actualWidth/actualHeight
        let maxRatio: CGFloat = maxWidth/maxHeight
        let compressionQuality = 0.5//50 percent compression
        
        if (actualHeight > maxHeight || actualWidth > maxWidth) {
            if(imgRatio < maxRatio) {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            } else if(imgRatio > maxRatio) {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            } else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        
        let rect: CGRect = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
        UIGraphicsBeginImageContext(rect.size)
        self.draw(in: rect)
        let image: UIImage  = UIGraphicsGetImageFromCurrentImageContext()!
        let imageData = UIImageJPEGRepresentation(image, CGFloat(compressionQuality))
        UIGraphicsEndImageContext()
        
        let resizedImage = UIImage(data: imageData!)
        return resizedImage!
    }
}


extension CGPoint : Hashable {
    public var hashValue: Int {
        return Int(x).hashValue << 32 ^ Int(y).hashValue
    }
    
    func strideUpY(to limit : CGFloat = 7) -> StrideTo<CGFloat> {
        return stride(from: y.rounded(), to: y.rounded() + limit, by: 1)
    }
    
    func strideDownY(to limit : CGFloat = 7) -> StrideTo<CGFloat> {
        return stride(from: y.rounded(), to: y.rounded() - limit, by: -1)
    }
    
    func strideUpX(to limit : CGFloat = 7) -> StrideTo<CGFloat> {
        return stride(from: x.rounded(), to: x.rounded() + limit, by: 1)
    }
    
    func strideDownX(to limit : CGFloat = 7) -> StrideTo<CGFloat> {
        return stride(from: x.rounded(), to: x.rounded() - limit, by: -1)
    }
}

extension Color {
    static let eclipseOrange = UIColor.init(r: 227, g: 94, b: 5)
    static let lead = UIColor.init(r: 33, g: 33, b: 33)
}

