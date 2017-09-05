//
//  PrivacyPolicyViewController.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 8/15/17.
//  Copyright © 2017 Arlindo Goncalves. All rights reserved.
//

import UIKit
import Material
import Eureka

class PrivacyPolicyViewController: UIViewController, TypedRowControllerType {
    
    var row: RowOf<String>!
    var onDismissCallback: ((UIViewController) -> ())?
    
    lazy var headerView : ShrinkableHeaderView = {
        let view = ShrinkableHeaderView(title: "Privacy Policy", titleColor: .black)
        view.backgroundColor = Color.NavBarColor
        view.maxHeaderHeight = 60
        view.isShrinkable = false
        return view
    }()
    
    lazy var backBtn : UIButton = {
        var btn = UIButton(type: .system)
        btn.addSqueeze()
        btn.setImage(#imageLiteral(resourceName: "left-small").withRenderingMode(.alwaysTemplate), for: .normal)
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(close), for: .touchUpInside)
        btn.accessibilityLabel = "Back"
        return btn
    }()
    
    var infoTextView : UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textAlignment = .left
        tv.font = UIFont.getDefautlFont(.meduium, size: 17)
        tv.isEditable = false
        tv.textContainer.lineBreakMode = .byWordWrapping
        tv.textContainerInset = UIEdgeInsetsMake(0, 10, 0, 10)
        tv.backgroundColor = UIColor(r: 249, g: 249, b: 249)
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setText()
    }

    func setupViews() {
        view.backgroundColor = headerView.backgroundColor
        view.addSubviews(headerView, infoTextView)
        
        headerView.headerHeightConstraint = headerView.anchor(topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0,widthConstant: 0, heightConstant: headerView.maxHeaderHeight).last!
        
        headerView.addSubviews(backBtn)
        backBtn.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        backBtn.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 10).isActive = true
        
        self.infoTextView.anchorToTop(headerView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    }
    
    func setText() {
        let bullet1 = "\u{2022}Crashlytics:\n\tFor the capture and collection of anonymous crash logs to help us identify bugs in our software. The Crashlytics Privacy Policy can be found at \nhttp://try.crashlytics.com/terms/\n\n"
        let bullet2 = "\u{2022}Fabric SDK:\n\tProvides us with the ability to capture and collect anonymous crash logs through the Crashlytics service: \nhttps://fabric.io/terms\n\n"
        let bullet3 = "\u{2022}Apple Analytics:\n\t(If enabled by user) For the collection of anonymous analytical data to help us better understand how our customers and users use our Services. App analytics is covered under the Apple Privacy Policy: \nhttps://www.apple.com/privacy/\n\n"
        
        let policys = bullet1+bullet2+bullet3
        
        infoTextView.text = policys
    }
    
    
    func createParagraphAttribute() ->NSParagraphStyle {
        var paragraphStyle: NSMutableParagraphStyle
        paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 0, options: NSDictionary() as! [String : AnyObject])]
        paragraphStyle.defaultTabInterval = 15
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.headIndent = 15
        
        return paragraphStyle
    }
    

    @objc private func close() {
        self.dismiss(animated: true, completion: nil)
    }
}
