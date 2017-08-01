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
import AudioKit
import BRYXBanner

struct Event {
    var name: String
    var description : NSAttributedString?
    var image : UIImage?
    
    init(name: String) {
        self.name = name
        let text = Utility.getFile(name, type: "txt")
        self.description = NSAttributedString(string: text ?? "", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.getDefautlFont(.meduium, size: 18)])
        
        self.image = UIImage(named: name)
    }
}


class RumbleMapViewController: UIViewController {
    
    //    var EventImages = [Event(name: "First Contact"),
    //                       Event(name: "Baily's Beads"),
    //                       Event(name: "Corona"),
    //                       Event(name: "Diamond Ring"),
    //                       Event(name: "Helmet Streamers"),
    //                       Event(name: "Prominence"),
    //                       Event(name: "Sun as a Star"),
    //                       Event(name: "Totality")]
    
    var EventImages = [Event(name: "Baily's Beads"),
                       Event(name: "Corona"),
                       Event(name: "Diamond Ring"),
                       Event(name: "Helmet Streamers"),
                       Event(name: "Prominence")]
    
    
    
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
    
    var rumbleMap: RumbleMap?
    
    var currentIndex = 0
    
    var modScale : CGFloat = 6
    
    
    var stopGesture : UITapGestureRecognizer?
    
    var isSessionActive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        configureView()
        loadImages()
        setText()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(leftApplication), name: .UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(returnToApplication), name: .UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceConnectedNotification), name: Notification.Name.AVAudioSessionRouteChange, object: nil)
        // add interruption handler
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(_:)), name: NSNotification.Name.AVAudioSessionInterruption, object: nil)
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
        
        let height = rumbleBtn.frame.height
        let rWidth = rumbleBtn.frame.width
        let bWidth = descriptionBtn.frame.width
        
        rumbleBtn.setBackgroundImage(UIImage.selectionIndiciatorImage(color: UIColor.init(r: 227, g: 94, b: 5), size: CGSize.init(width: rWidth, height: height), lineWidth: 2, position: .bottom)?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        rumbleBtn.tintColor = UIColor.init(r: 227, g: 94, b: 5)
        rumbleBtn.accessibilityTraits |= UIAccessibilityTraitSelected
        
        descriptionBtn.setBackgroundImage(UIImage.selectionIndiciatorImage(color: .white, size: CGSize.init(width: bWidth, height: height), lineWidth: 2, position: .bottom)?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        descriptionTextView.textContainerInset = UIEdgeInsetsMake(20, 20, 10, 20)
        descriptionTextView.accessibilityTraits = UIAccessibilityTraitStaticText
    }
    
    
    func setText() {
        titleLabel.font = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(fontName: .bold, textStyle: .headline), size: 0)
    }
    
    func loadImages() {
        currentIndex = 0
        titleLabel.text = EventImages[currentIndex].name
        descriptionTextView.attributedText = EventImages[currentIndex].description
        previewImageView.image = EventImages[currentIndex].image
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openRumbleMap() {
        if !rumbleMapShowing {
            self.tabBarController?.setTabBarVisible(visible: false, animated: true)
            self.updateStatusBar(hide: true)
            
            rumbleMap = RumbleMap()
            rumbleMap?.closeCompletion = {
                self.view.accessibilityElementsHidden = false
                self.tabBarController?.tabBar.accessibilityElementsHidden = false
                self.updateStatusBar(hide: false)
                self.tabBarController?.setTabBarVisible(visible: true, animated: true)
            }
            
            rumbleMap?.show(EventImages[currentIndex]){
                self.view.accessibilityElementsHidden = true
                self.tabBarController?.tabBar.accessibilityElementsHidden = true
            }
        }
    }
    
    
    @IBAction func nextImage(_ sender: Any) {
        currentIndex += 1
        
        if currentIndex > EventImages.count-1 {
            currentIndex = 0
        }
        titleLabel.text = EventImages[currentIndex].name
        descriptionTextView.attributedText = EventImages[currentIndex].description
        previewImageView.image = EventImages[currentIndex].image
    }
    
    @IBAction func previousImage(_ sender: Any) {
        currentIndex -= 1
        
        if currentIndex < 0 {
            currentIndex = EventImages.count-1
        }
        titleLabel.text = EventImages[currentIndex].name
        descriptionTextView.attributedText = EventImages[currentIndex].description
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
            descriptionBtn.accessibilityTraits ^= UIAccessibilityTraitSelected
            
        } else if sender == descriptionBtn {
            descriptionTextView.isHidden = false
            startRumbleBtn.isHidden = true
            previewImageView.isHidden = true
            rumbleBtn.tintColor = UIColor(r: 33, g: 33, b: 33)
            rumbleBtn.accessibilityHint = nil
            rumbleBtn.accessibilityTraits ^= UIAccessibilityTraitSelected
        }
        
        sender.tintColor = UIColor.init(r: 227, g: 94, b: 5)
        sender.accessibilityTraits |= UIAccessibilityTraitSelected
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: Notification Handlers
    func leftApplication() {
        rumbleMap?.setSession(active: false)//Left
    }
    
    func returnToApplication(){
        rumbleMap?.setSession(active: true)//Returned
    }
    
    
    /// Notification handler for AVAudioSessionRouteChange to catch changes to device connection from the audio jack.
    ///
    /// - Parameter notification: Notification object cointaing AVAudioSessionRouteChange data
    func deviceConnectedNotification(notification: Notification){
        
        let audioRouteChangeReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt
        switch audioRouteChangeReason {
        case AVAudioSessionRouteChangeReason.newDeviceAvailable.rawValue: ///device is connected
            rumbleMap?.setSession(active: true)
            break
            
        case AVAudioSessionRouteChangeReason.oldDeviceUnavailable.rawValue: ///device is not connected
            
            rumbleMap?.setSession(active: true)
            break
            
        default:
            break
        }
    }
    
    //TODO: Implement the recording to pause while interruption is in prpogress and restart after interruption is stoped
    /// Interruption Handler
    ///
    /// - Parameter notification: Device generated notification about interruption
    func handleInterruption(_ notification: Notification) {
        let theInterruptionType = (notification as NSNotification).userInfo![AVAudioSessionInterruptionTypeKey] as! UInt
        NSLog("Session interrupted > --- %@ ---\n", theInterruptionType == AVAudioSessionInterruptionType.began.rawValue ? "Begin Interruption" : "End Interruption")
        
        if theInterruptionType == AVAudioSessionInterruptionType.began.rawValue {
            
        }
        
        if theInterruptionType == AVAudioSessionInterruptionType.ended.rawValue {
            
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        //TODO: Stop RumbleMap
        rumbleMap?.willRotate()
    }
    
    
    var rumbleMapShowing = false
    
    func updateStatusBar(hide: Bool) {
        rumbleMapShowing = hide
        UIView.animate(withDuration: 0.2, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        })
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return .fade
    }
    
    override var prefersStatusBarHidden: Bool {
        return rumbleMapShowing
    }
}
