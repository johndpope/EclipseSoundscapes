//
//  ShrinkableHeaderView.swift
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

@objc protocol ShrinkableHeaderViewDelegate : class {
    @objc optional func setScrollPosition(position: CGFloat)
}

class ShrinkableHeaderView : UIView {
    
    
    weak var delegate : ShrinkableHeaderViewDelegate?
    
    var maxHeaderHeight: CGFloat = 44
    var minHeaderHeight: CGFloat = 0
    var previousScrollOffset: CGFloat = 0
    
    var headerHeightConstraint : NSLayoutConstraint!
    
    var isShrinkable = true
    
    var titleLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.getDefautlFont(.bold, size: 18)
        label.accessibilityTraits = UIAccessibilityTraitHeader
        return label
    }()
    
    var separatorLine : UIView = {
        var view = UIView()
        view.backgroundColor = Color.NavBarSeparatorColor
        return view
    }()
    
    var titleText : String? {
        didSet {
            self.titleLabel.text = titleText
        }
    }
    
    var textColor : UIColor = .black {
        didSet {
            titleLabel.textColor = textColor
        }
    }
    
    init(title: String? = nil, titleColor: UIColor = .black) {
        super.init(frame: .zero)
        self.textColor = titleColor
        self.titleText = title
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        addSubviews(titleLabel, separatorLine)
        titleLabel.text = titleText
        titleLabel.textColor = textColor
        titleLabel.center(in: self)
        titleLabel.setSize(widthAnchor: widthAnchor, heightAnchor: heightAnchor)
        
        separatorLine.anchor(nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0.5)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let scrollDiff = scrollView.contentOffset.y - self.previousScrollOffset
        
        let absoluteTop: CGFloat = 0;
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height;
        
        let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom
        
        if canAnimateHeader(scrollView) {
            
            // Calculate new header height
            var newHeight = self.headerHeightConstraint.constant
            if isScrollingDown {
                newHeight = max(self.minHeaderHeight, self.headerHeightConstraint.constant - abs(scrollDiff))
            } else if isScrollingUp {
                newHeight = min(self.maxHeaderHeight, self.headerHeightConstraint.constant + abs(scrollDiff))
            }
            
            // Header needs to animate
            if newHeight != self.headerHeightConstraint.constant {
                self.headerHeightConstraint.constant = newHeight
                self.updateHeader()
                delegate?.setScrollPosition?(position: self.previousScrollOffset)
            }
            
            self.previousScrollOffset = scrollView.contentOffset.y
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidStopScrolling()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollViewDidStopScrolling()
        }
    }
    
    func scrollViewDidStopScrolling() {
        //let range = self.maxHeaderHeight - self.minHeaderHeight
        let collapsePoint = self.minHeaderHeight //+ (range / 4)
        
        if self.headerHeightConstraint.constant > collapsePoint {
            self.expandHeader()
        } else {
            self.collapseHeader()
        }
    }
    
    func canAnimateHeader(_ scrollView: UIScrollView) -> Bool {
        // Calculate the size of the scrollView when header is collapsed
        let scrollViewMaxHeight = scrollView.frame.height + self.headerHeightConstraint.constant - minHeaderHeight
        
        // Make sure that when header is collapsed, there is still room to scroll
        return scrollView.contentSize.height > scrollViewMaxHeight && isShrinkable
    }
    
    func collapseHeader() {
        self.headerHeightConstraint.constant = self.minHeaderHeight
        UIView.animate(withDuration: 0.2, animations: {
            
            self.updateHeader()
            self.layoutIfNeeded()
            self.superview?.layoutIfNeeded()
        })
    }
    
    func expandHeader() {
        self.headerHeightConstraint.constant = self.maxHeaderHeight
        UIView.animate(withDuration: 0.2, animations: {
            self.updateHeader()
            self.layoutIfNeeded()
            self.superview?.layoutIfNeeded()
        })
    }
    
    func updateHeader() {
        let range = self.maxHeaderHeight - self.minHeaderHeight
        let openAmount = self.headerHeightConstraint.constant - self.minHeaderHeight
        let percentage = openAmount / range
        
        //        self.titleTopConstraint.constant = -openAmount + 10
        self.titleLabel.alpha = percentage
    }
}
