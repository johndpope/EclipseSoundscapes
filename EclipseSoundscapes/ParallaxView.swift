//
//  ParallaxView.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 8/28/17.
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

final class ParallaxView: UIView {
    
    override var backgroundColor: UIColor? {
        didSet {
            panningView.backgroundColor = backgroundColor
        }
    }
    
    fileprivate var heightLayoutConstraint = NSLayoutConstraint()
    fileprivate var bottomLayoutConstraint = NSLayoutConstraint()
    fileprivate var containerLayoutConstraint = NSLayoutConstraint()
    
    fileprivate var containerView = UIView()
    fileprivate var panningView = UIView()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(containerView)
        containerLayoutConstraint = containerView.anchor(nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: CGFloat.leastNonzeroMagnitude).last!
        
        
        panningView = UIView()
        panningView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(panningView)
        
        let contraints = panningView.anchor(nil, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: CGFloat.leastNonzeroMagnitude)
        
        bottomLayoutConstraint = contraints[1]
        heightLayoutConstraint = contraints.last!
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        containerLayoutConstraint.constant = scrollView.contentInset.top
        let offsetY = -(scrollView.contentOffset.y + scrollView.contentInset.top)
        bottomLayoutConstraint.constant = offsetY >= 0 ? 0 : -offsetY / 2
        heightLayoutConstraint.constant = max(offsetY + scrollView.contentInset.top, scrollView.contentInset.top)
    }
}
