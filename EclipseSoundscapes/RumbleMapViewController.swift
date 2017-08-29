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
    
    @IBOutlet weak var descriptionBtn: UIButton!
    @IBOutlet weak var rumbleBtn: UIButton!
    
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var previousBtn: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var startRumbleBtn: UIButton!
    @IBOutlet weak var previewImageView: UIImageView!
    
    var currentIndex = 0
    
    var modScale : CGFloat = 6
    
    
    var stopGesture : UITapGestureRecognizer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        controlView.isAccessibilityElement = false
        controlView.accessibilityElements = [previousBtn, titleLabel, nextBtn]
        
        configureView()
        loadImages()
        setText()
        
        addObservers()
    }
    
    func addObservers() {
        NotificationHelper.addObserver(self, reminders: [.allDone,.totality,.contact1], selector: #selector(catchReminderNotification(notification:)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    func catchReminderNotification(notification: Notification) {
        guard let reminder = notification.userInfo?["Reminder"] as? Reminder else {
            return
        }
        reloadViews(for: reminder)
        
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
    
    func configureView() {
        let background = UIView.rombusPattern()
        background.frame = view.bounds
        background.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(background, at: 0)
        
        startRumbleBtn.addTarget(self, action: #selector(openRumbleMap), for: .touchUpInside)
        startRumbleBtn.titleLabel?.numberOfLines = 0
        startRumbleBtn.titleLabel?.textAlignment = .center
        
        nextBtn.setImage(#imageLiteral(resourceName: "Right_Arrow").withRenderingMode(.alwaysTemplate), for: .normal)
        nextBtn.tintColor = .white
        nextBtn.accessibilityHint = "Shows the next Eclipse Image"
        
        
        previousBtn.setImage(#imageLiteral(resourceName: "Left_Arrow").withRenderingMode(.alwaysTemplate), for: .normal)
        previousBtn.tintColor = .white
        previousBtn.accessibilityHint = "Shows the previous Eclipse Image"
        
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.accessibilityTraits = UIAccessibilityTraitHeader
        
        let height = rumbleBtn.frame.height
        let rWidth = rumbleBtn.frame.width
        let bWidth = descriptionBtn.frame.width
        
        descriptionBtn.setBackgroundImage(UIImage.selectionIndiciatorImage(color: UIColor.init(r: 227, g: 94, b: 5), size: CGSize.init(width: rWidth, height: height), lineWidth: 2, position: .bottom)?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        descriptionBtn.tintColor = UIColor.init(r: 227, g: 94, b: 5)
        descriptionBtn.accessibilityTraits |= UIAccessibilityTraitSelected
        
        rumbleBtn.setBackgroundImage(UIImage.selectionIndiciatorImage(color: .white, size: CGSize.init(width: bWidth, height: height), lineWidth: 2, position: .bottom)?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        descriptionTextView.textContainerInset = UIEdgeInsetsMake(20, 20, 10, 20)
        descriptionTextView.accessibilityTraits = UIAccessibilityTraitStaticText
    }
    
    
    func setText() {
        titleLabel.font = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(fontName: .bold, textStyle: .headline), size: 0)
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
    
    
    @IBAction func nextImage(_ sender: Any) {
        currentIndex += 1
        
        if currentIndex > EventImages.count-1 {
            currentIndex = 0
        }
        titleLabel.text = EventImages[currentIndex].name
        descriptionTextView.attributedText = EventImages[currentIndex].info
        previewImageView.image = EventImages[currentIndex].image
    }
    
    @IBAction func previousImage(_ sender: Any) {
        currentIndex -= 1
        
        if currentIndex < 0 {
            currentIndex = EventImages.count-1
        }
        titleLabel.text = EventImages[currentIndex].name
        descriptionTextView.attributedText = EventImages[currentIndex].info
        previewImageView.image = EventImages[currentIndex].image
    }
    
    func unregisterGesture(for view: UIView) {
        if let recognizers = view.gestureRecognizers {
            for recognizer in recognizers {
                view.removeGestureRecognizer(recognizer)
            }
        }
    }
    @IBAction func switchState(_ sender: UIButton) {
        if sender == rumbleBtn {
            descriptionTextView.isHidden = true
            startRumbleBtn.isHidden = false
            previewImageView.isHidden = false
            descriptionBtn.tintColor = UIColor(r: 33, g: 33, b: 33)
            descriptionBtn.accessibilityTraits &= ~UIAccessibilityTraitSelected
            
        } else if sender == descriptionBtn {
            descriptionTextView.isHidden = false
            startRumbleBtn.isHidden = true
            previewImageView.isHidden = true
            rumbleBtn.tintColor = UIColor(r: 33, g: 33, b: 33)
            rumbleBtn.accessibilityHint = nil
            rumbleBtn.accessibilityTraits &= ~UIAccessibilityTraitSelected
        }
        
        sender.tintColor = UIColor.init(r: 227, g: 94, b: 5)
        sender.accessibilityTraits ^= UIAccessibilityTraitSelected
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
