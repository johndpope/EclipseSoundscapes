//
//  RumbleMapViewController.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 6/16/17.
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
import BRYXBanner

class Event: NSObject {
    var name: String
    var info : NSAttributedString?
    var image : UIImage?
    
    init(name: String) {
        self.name = name
        let text = Utility.getFile(name, type: "txt")
        self.info = NSAttributedString(string: text ?? "", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.getDefautlFont(.meduium, size: 18)])
        
        self.image = UIImage(named: name)
    }
    
    init(name: String, resourceName: String, image: UIImage){
        self.name = name
        let text = Utility.getFile(resourceName, type: "txt")
        self.info = NSAttributedString(string: text ?? "", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.getDefautlFont(.meduium, size: 18)])
        
        self.image = image
    }
}


class RumbleMapViewController: UIViewController {
    
    var EventImages : [Event]!
    
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    lazy var descriptionBtn: UIButton = {
        var btn = UIButton(type: .system)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle("Description", for: .normal)
        btn.titleLabel?.font = UIFont.getDefautlFont(.meduium, size: 20)
        btn.tintColor = Color.eclipseOrange
        btn.accessibilityTraits |= UIAccessibilityTraitSelected
        btn.backgroundColor = Color.lead
        btn.addTarget(self, action: #selector(switchState(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var rumbleBtn: UIButton = {
        var btn = UIButton(type: .system)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle("Rumble Map", for: .normal)
        btn.titleLabel?.font = UIFont.getDefautlFont(.meduium, size: 20)
        btn.backgroundColor = Color.lead
        btn.tintColor = Color.lead
        btn.addTarget(self, action: #selector(switchState(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var nextBtn: UIButton = {
        var btn = UIButton(type: .system)
        btn.addSqueeze()
        btn.setImage(#imageLiteral(resourceName: "Right_Arrow").withRenderingMode(.alwaysTemplate), for: .normal)
        btn.tintColor = .white
        btn.accessibilityHint = "Shows the next Eclipse Image"
        btn.addTarget(self, action: #selector(nextImage(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var previousBtn: UIButton = {
        var btn = UIButton(type: .system)
        btn.addSqueeze()
        btn.setImage(#imageLiteral(resourceName: "Left_Arrow").withRenderingMode(.alwaysTemplate), for: .normal)
        btn.tintColor = .white
        btn.accessibilityHint = "Shows the previous Eclipse Image"
        btn.addTarget(self, action: #selector(previousImage(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var startRumbleBtn: UIButton = {
        var btn = UIButton(type: .system)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle("Press to Interact with Rumble Map", for: .normal)
        btn.titleLabel?.font = UIFont.getDefautlFont(.bold, size: 28)
        btn.titleLabel?.numberOfLines = 0
        btn.titleLabel?.textAlignment = .center
        btn.addTarget(self, action: #selector(openRumbleMap), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()
    
    
    var fillerView : UIView = {
        let view = UIView()
        view.backgroundColor = Color.lead
        return view
    }()
    
    var controlView: UIView = {
        var view = UIView()
        view.backgroundColor = Color.lead
        return view
    }()
    
    var titleLabel: UILabel = {
        var label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.getDefautlFont(.extraBold, size: 22)
        label.adjustsFontSizeToFitWidth = true
        label.accessibilityTraits = UIAccessibilityTraitHeader
        return label
    }()
    
    
    
    var descriptionTextView: UITextView = {
        var tv = UITextView()
        tv.textContainerInset = UIEdgeInsetsMake(20, 20, 10, 20)
        tv.accessibilityTraits = UIAccessibilityTraitStaticText
        tv.backgroundColor = .black
        tv.isEditable = false
        return tv
    }()
    
    
    var previewImageView: UIImageView = {
        var iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.isHidden = true
        return iv
    }()
    
    var stackView : UIStackView = {
       var sv = UIStackView()
        sv.alignment = .fill
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        return sv
    }()
    
    var currentIndex = 0
    
    var modScale : CGFloat = 6
    
    var stopGesture : UITapGestureRecognizer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .black
        setupViews()
        loadImages()
        addObservers()
    }
    
    func addObservers() {
        NotificationHelper.addObserver(self, reminders: [.allDone,.totality,.contact1], selector: #selector(catchReminderNotification(notification:)))
    }
    
    func catchReminderNotification(notification: Notification) {
        guard let reminder = notification.userInfo?["Reminder"] as? Reminder else {
            return
        }
        reloadViews(for: reminder)
        
    }
    
    func setupViews() {
        view.addSubviews(fillerView, controlView, stackView, previewImageView, startRumbleBtn, descriptionTextView)
        
        fillerView.anchorToTop(view.topAnchor, left: view.leftAnchor, bottom: controlView.topAnchor, right: view.rightAnchor)
        
        controlView.anchor(topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: stackView.topAnchor, right: view.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 60)
        
        controlView.addSubviews(previousBtn, titleLabel, nextBtn)
        
        titleLabel.centerYAnchor.constraint(equalTo: controlView.centerYAnchor).isActive = true
        titleLabel.anchor(controlView.topAnchor, left: previousBtn.rightAnchor, bottom: controlView.bottomAnchor, right: nextBtn.leftAnchor, topConstant: 2, leftConstant: 2, bottomConstant: 2, rightConstant: 2, widthConstant: 0, heightConstant: 0)
        
        previousBtn.setSize(35, height: 35)
        previousBtn.leftAnchor.constraint(equalTo: controlView.leftAnchor, constant: 10).isActive = true
        previousBtn.centerYAnchor.constraint(equalTo: controlView.centerYAnchor).isActive = true
        
        nextBtn.setSize(35, height: 35)
        nextBtn.rightAnchor.constraint(equalTo: controlView.rightAnchor, constant: -10).isActive = true
        nextBtn.centerYAnchor.constraint(equalTo: controlView.centerYAnchor).isActive = true
        
        stackView.anchor(nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50)
        
        stackView.addArrangedSubview(descriptionBtn)
        stackView.addArrangedSubview(rumbleBtn)
        
        previewImageView.anchorToTop(stackView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        startRumbleBtn.anchorToTop(stackView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        descriptionTextView.anchorToTop(stackView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height = rumbleBtn.bounds.height
        let rWidth = rumbleBtn.bounds.width
        let bWidth = descriptionBtn.bounds.width
        
        descriptionBtn.setBackgroundImage(UIImage.selectionIndiciatorImage(color: Color.eclipseOrange, size: CGSize.init(width: rWidth, height: height), lineWidth: 2, position: .bottom)?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        
        rumbleBtn.setBackgroundImage(UIImage.selectionIndiciatorImage(color: .white, size: CGSize.init(width: bWidth, height: height), lineWidth: 2, position: .bottom)?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    
    
    func reloadViews(for reminder : Reminder) {
        if reminder.contains(.allDone) || reminder.contains(.totality) {
            EventImages = [Event(name: "First Contact"),Event(name: "Baily's Beads"),
                           Event(name: "Baily's Beads Zoomed", resourceName: "Baily's Beads", image: #imageLiteral(resourceName: "Baily's Beads Zoomed")),
                           Event(name: "Corona"),
                           Event(name: "Diamond Ring"),
                           Event(name: "Helmet Streamers"),
                           Event(name: "Helmet Streamers Zoomed", resourceName: "Helmet Streamers", image: #imageLiteral(resourceName: "Helmet Streamers Zoomed")),
                           Event(name: "Prominence"),
                           Event(name: "Prominence Zoomed", resourceName: "Prominence", image: #imageLiteral(resourceName: "Prominence Zoomed")),
                           Event(name: "Totality")]
            
        } else if reminder.contains(.contact1) {
            EventImages = [Event(name: "First Contact"),Event(name: "Baily's Beads"),
                           Event(name: "Baily's Beads Zoomed", resourceName: "Baily's Beads", image: #imageLiteral(resourceName: "Baily's Beads Zoomed")),
                           Event(name: "Corona"),
                           Event(name: "Diamond Ring"),
                           Event(name: "Helmet Streamers"),
                           Event(name: "Helmet Streamers Zoomed", resourceName: "Helmet Streamers", image: #imageLiteral(resourceName: "Helmet Streamers Zoomed")),
                           Event(name: "Prominence"),
                           Event(name: "Prominence Zoomed", resourceName: "Prominence", image: #imageLiteral(resourceName: "Prominence Zoomed"))]
            currentIndex += 1
        }
    }
    
    func loadImages() {
        EventImages = [Event(name: "Baily's Beads"),
                       Event(name: "Baily's Beads Zoomed", resourceName: "Baily's Beads", image: #imageLiteral(resourceName: "Baily's Beads Zoomed")),
                       Event(name: "Corona"),
                       Event(name: "Diamond Ring"),
                       Event(name: "Helmet Streamers"),
                       Event(name: "Helmet Streamers Zoomed", resourceName: "Helmet Streamers", image: #imageLiteral(resourceName: "Helmet Streamers Zoomed")),
                       Event(name: "Prominence"),
                       Event(name: "Prominence Zoomed", resourceName: "Prominence", image: #imageLiteral(resourceName: "Prominence Zoomed"))
        ]
        
        
        if UserDefaults.standard.bool(forKey: "Contact1Done") {
            reloadViews(for: .contact1)
        }
        
        if UserDefaults.standard.bool(forKey: "TotalityDone") {
            reloadViews(for: .totality)
        }
        
        
        titleLabel.text = EventImages[currentIndex].name
        descriptionTextView.attributedText = EventImages[currentIndex].info
        previewImageView.image = EventImages[currentIndex].image
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openRumbleMap() {
        let interactiveVC = RumbleMapInteractiveViewController()
        interactiveVC.event = EventImages[currentIndex]
        self.present(interactiveVC, animated: true, completion: nil)
    }
    
    
    func nextImage(_ sender: UIButton) {
        currentIndex += 1
        
        if currentIndex > EventImages.count-1 {
            currentIndex = 0
        }
        titleLabel.text = EventImages[currentIndex].name
        descriptionTextView.attributedText = EventImages[currentIndex].info
        previewImageView.image = EventImages[currentIndex].image
    }
    
    func previousImage(_ sender: UIButton) {
        currentIndex -= 1
        
        if currentIndex < 0 {
            currentIndex = EventImages.count-1
        }
        titleLabel.text = EventImages[currentIndex].name
        descriptionTextView.attributedText = EventImages[currentIndex].info
        previewImageView.image = EventImages[currentIndex].image
    }
    
    func switchState(_ sender: UIButton) {
        if sender == rumbleBtn {
            descriptionTextView.isHidden = true
            startRumbleBtn.isHidden = false
            previewImageView.isHidden = false
            descriptionBtn.tintColor = Color.lead
            descriptionBtn.accessibilityTraits &= ~UIAccessibilityTraitSelected
            
        } else if sender == descriptionBtn {
            descriptionTextView.isHidden = false
            startRumbleBtn.isHidden = true
            previewImageView.isHidden = true
            rumbleBtn.tintColor = Color.lead
            rumbleBtn.accessibilityHint = nil
            rumbleBtn.accessibilityTraits &= ~UIAccessibilityTraitSelected
        }
        
        sender.tintColor = Color.eclipseOrange
        sender.accessibilityTraits ^= UIAccessibilityTraitSelected
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
