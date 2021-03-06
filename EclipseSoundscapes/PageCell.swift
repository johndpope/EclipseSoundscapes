//
//  PageCell.swift
//  audible
//
//  Created by Brian Voong on 9/1/16.
//  Copyright © 2016 Lets Build That App. All rights reserved.
//

import UIKit

class PageCell: UICollectionViewCell {
    
    static let InfoHeight = UIScreen.main.bounds.height/3 + 15
    
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
            
            let attributedText = NSMutableAttributedString(string: page.title, attributes: [NSAttributedStringKey.font: UIFont.getDefautlFont(.meduium, size: 20), NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.paragraphStyle: paragraphStyle])
            
            attributedText.append(NSAttributedString(string: "\n\n\(page.message)", attributes: [NSAttributedStringKey.font: UIFont.getDefautlFont(.meduium, size: 14), NSAttributedStringKey.foregroundColor: color, ]))
            
            let paragraphStyle2 = NSMutableParagraphStyle()
            paragraphStyle2.alignment = .center
            
            let start = page.title.characters.count
            let length = attributedText.string.characters.count - start
            attributedText.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle2, range: NSRange(location: start, length: length))
            
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
        infoView.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, heightConstant: PageCell.InfoHeight)
        
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
        tv.accessibilityTraits = UIAccessibilityTraitStaticText | UIAccessibilityTraitHeader
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





