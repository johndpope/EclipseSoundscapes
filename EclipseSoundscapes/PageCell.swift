//
//  PageCell.swift
//  audible
//
//  Created by Brian Voong on 9/1/16.
//  Copyright © 2016 Lets Build That App. All rights reserved.
//

import UIKit

class PageCell: UICollectionViewCell {
    
    var page: Page? {
        didSet {
            
            guard let page = page else {
                return
            }
            
            let imageName = page.imageName
            
            imageView.image = UIImage(named: imageName)
            
            let color = UIColor(white: 0.2, alpha: 1)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributedText = NSMutableAttributedString(string: page.title, attributes: [NSFontAttributeName: UIFont.getDefautlFont(.meduium, size: 20), NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: paragraphStyle])
            
            attributedText.append(NSAttributedString(string: "\n\n\(page.message)", attributes: [NSFontAttributeName: UIFont.getDefautlFont(.meduium, size: 14), NSForegroundColorAttributeName: color, ]))
            
            let paragraphStyle2 = NSMutableParagraphStyle()
            paragraphStyle2.alignment = .center
            
            let start = page.title.characters.count
            let length = attributedText.string.characters.count - start
            attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle2, range: NSRange(location: start, length: length))
            
            infoView.content = attributedText
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .yellow
        iv.image = UIImage(named: "page1")
        iv.clipsToBounds = true
        return iv
    }()
    
    let infoView : WalkthroughContentView = {
        var view = WalkthroughContentView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    let lineSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.9, alpha: 1)
        return view
    }()
    
    func setupViews() {
        addSubview(imageView)
        addSubview(infoView)
        addSubview(lineSeparatorView)
        
        imageView.anchorToTop(topAnchor, left: leftAnchor, bottom: infoView.topAnchor, right: rightAnchor)
        infoView.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, heightConstant: self.frame.height/4)
        
        lineSeparatorView.anchorToTop(nil, left: leftAnchor, bottom: infoView.topAnchor, right: rightAnchor)
        lineSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class WalkthroughContentView: UIView {
    
    var content: NSAttributedString? {
        didSet{
            self.contentTextView.attributedText = content
        }
    }
    
    var contentTextView : UITextView = {
        var tv = UITextView()
        tv.textContainerInset = UIEdgeInsetsMake(10, 10, 5, 10)
        tv.isEditable = false
        tv.backgroundColor = UIColor(r: 249, g: 249, b: 249)
        tv.accessibilityTraits = UIAccessibilityTraitStaticText
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(contentTextView)
        contentTextView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}





