//
//  RumbleMapViewController.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 6/16/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import UIKit
import AudioKit

struct EclipseImage {
    var image : UIImage
    var name : String
    
    init(name : String, image: UIImage) {
        self.name = name
        self.image = image
    }
}

class RumbleMapViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var rumbleMapContainer: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var rightArrowBtn: UIButton!
    @IBOutlet weak var leftArrowBtn: UIButton!
    @IBOutlet weak var startBtn: UIButton!
    
    var eclipseImages = [EclipseImage]()
    var currentIndex = 0
    
    var boomBox : AKFMOscillator!
    var envelope : AKAmplitudeEnvelope!
    var mixer : AKMixer!
    
    var dataGainControl : Double = 0.0 {
        didSet {
            self.mixer.volume = self.dataGainControl
        }
    }
    
    var isZooming = false
    var zoomScale : CGFloat = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupRumbleSounds()
        setupZoom()
        registerGestures()
        setupView()
        loadImages()
    }
    
    func setupRumbleSounds() {
        
        do {
            try AKSettings.setSession(category: .playback)
            try AKSettings.session.setActive(true, with: .notifyOthersOnDeactivation)
            AKSettings.playbackWhileMuted = true
            
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        
        boomBox = AKFMOscillator(waveform: AKTable.init(), baseFrequency: 55, carrierMultiplier: 4, modulatingMultiplier: 1, modulationIndex: 1, amplitude: 1)
        
        boomBox.rampTime = 0.01
        
        envelope = AKAmplitudeEnvelope(boomBox, attackDuration: 1.0, decayDuration: 0.1, sustainLevel: 1.0, releaseDuration: 0.1)
        
        mixer = AKMixer.init(envelope)
        
        AudioKit.output = mixer
        AudioKit.start()
    }
    
    func setupView() {
        rightArrowBtn.setImage(#imageLiteral(resourceName: "Right_Arrow").withRenderingMode(.alwaysTemplate), for: .normal)
        rightArrowBtn.tintColor = .white
        rightArrowBtn.accessibilityLabel = "Next"
        rightArrowBtn.accessibilityHint = "Shows the next Eclipse Image"
        rightArrowBtn.accessibilityTraits = UIAccessibilityTraitButton
        
        leftArrowBtn.setImage(#imageLiteral(resourceName: "Left_Arrow").withRenderingMode(.alwaysTemplate), for: .normal)
        leftArrowBtn.tintColor = .white
        leftArrowBtn.accessibilityLabel = "Previous"
        leftArrowBtn.accessibilityHint = "Shows the previous Eclipse Image"
        leftArrowBtn.accessibilityTraits = UIAccessibilityTraitButton
        
        contactImage.isAccessibilityElement = true
        contactImage.accessibilityLabel = "RumbleMap"
        contactImage.accessibilityTraits = UIAccessibilityTraitAllowsDirectInteraction
        
        startBtn.layer.cornerRadius = 10
        startBtn.accessibilityLabel = "Start"
        startBtn.accessibilityHint = "Begin interaction with Eclipse Images"
        startBtn.accessibilityTraits = UIAccessibilityTraitButton
        
        titleLabel.accessibilityTraits = UIAccessibilityTraitHeader // TODO: Add description here
    }
    
    func loadImages() {
        var names = ["Eclipse_1", "Eclipse_2", "Eclipse_3", "Eclipse_4"]
        for i in 0...names.count-1 {
            let eclipseImage = EclipseImage(name: "Contact Point \(i+1)", image: UIImage(named: names[i])!)
            eclipseImages.append(eclipseImage)
        }
        contactImage.image = eclipseImages[currentIndex].image
        titleLabel.text = eclipseImages[currentIndex].name
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func startRumbleMap(_ sender: Any) {
        startBtn.isHidden = true
        rumbleMapContainer.isHidden = false
        titleLabel.isHidden = false
        leftArrowBtn.isHidden = false
        rightArrowBtn.isHidden = false
        
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.titleLabel)
    }
    @IBAction func nextImage(_ sender: Any) {
        currentIndex += 1
        
        if currentIndex > eclipseImages.count-1 {
            currentIndex = 0
        }
        
        contactImage.image = eclipseImages[currentIndex].image
        titleLabel.text = eclipseImages[currentIndex].name
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, titleLabel)
    }
    @IBAction func previousImage(_ sender: Any) {
        currentIndex -= 1
        
        if currentIndex < 0 {
            currentIndex = eclipseImages.count-1
        }
        
        contactImage.image = eclipseImages[currentIndex].image
        titleLabel.text = eclipseImages[currentIndex].name
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, titleLabel)
    }
    
    func registerGestures() {
        contactImage.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        tapGesture.numberOfTapsRequired = 2
        rumbleMapContainer.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        rumbleMapContainer.addGestureRecognizer(panGesture)
        
        let touchDownGesture = UILongPressGestureRecognizer(target: self, action: #selector(touchDown(_:)))
        touchDownGesture.minimumPressDuration = 0
        touchDownGesture.delegate = self
        rumbleMapContainer.addGestureRecognizer(touchDownGesture)
    }
    
    func tap() {
        
        if self.scrollView.zoomScale != 1.0 {
            self.scrollView.setZoomScale(1.0, animated: true)
            print("Tapped!!")
        }
    }
    
    func unregisterGesture(for view: UIView) {
        if let recognizers = view.gestureRecognizers {
            for recognizer in recognizers {
                view.removeGestureRecognizer(recognizer)
            }
        }
    }
    
    func touchDown(_ recognizer: UILongPressGestureRecognizer) {
        
        if recognizer.state == .began && !isZooming {
            let location = recognizer.location(in: recognizer.view)
            if let grayScale = recognizer.view?.grayScale(point: location) {
                print(grayScale)
                dataGainControl = Double(grayScale)
            }
            
            boomBox.play()
            envelope.play()
            mixer.play()
            
        } else if recognizer.state == .ended {
            envelope.stop()
            mixer.stop()
        }
    }
    
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        
        if isZooming {
            return
        }
        
        if recognizer.state == .began || recognizer.state == .changed {
            let location = recognizer.location(in: recognizer.view)
            if let grayScale = recognizer.view?.grayScale(point: location) {
                print(grayScale)
                dataGainControl = Double(grayScale)
            }
        }
    }
    
    func setupZoom() {
        
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.flashScrollIndicators()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        scrollView.canCancelContentTouches = false
        scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.contactImage
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        isZooming = true
        envelope.stop()
        mixer.stop()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        isZooming = false
        
        if scale > zoomScale + 0.1 || scale < zoomScale - 0.1 {
            zoomScale = scale
            let zoomString = String.init(format: "Zoom scale %0.1f %%", zoomScale)
            contactImage.accessibilityValue = zoomString
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, zoomString)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension RumbleMapViewController : UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.contactImage
    }
}
