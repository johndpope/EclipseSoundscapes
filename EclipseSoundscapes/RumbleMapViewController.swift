//
//  RumbleMapViewController.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 6/16/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import UIKit
import AudioKit
import Localize_Swift

struct EclipseImage {
    var image : UIImage!
    
    init(image: UIImage) {
        self.image = image
    }
}

class RumbleMapViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var rumbleMapContainer: RumbleMapView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var rightArrowBtn: UIButton!
    @IBOutlet weak var leftArrowBtn: UIButton!
    
    var eclipseImages = [EclipseImage]()
    var currentIndex = 0
    
    var boomBox : AKFMOscillator!
    var envelope : AKAmplitudeEnvelope!
    var envelopeMixer : AKMixer!
    
    var whiteNoise : AKWhiteNoise!
    var whiteNoiseFilter : AKLowPassFilter!
    var whiteNoiseMixer : AKMixer!
    
    var masterMixer : AKMixer!
    
    var dataGainControl : Double = 0.0 {
        didSet {
            self.envelopeMixer.volume = self.dataGainControl
        }
    }
    
    var modControl : Double = 1.0 {
        didSet {
            if modControl < 1 {
                modControl += 1
            }
            self.boomBox.modulatingMultiplier = modControl
        }
    }
    
    var modScale : CGFloat = 4
    
    var isZooming = false
    var zoomScale : CGFloat = 1.0
    
    var markerContainer : MarkerContainer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupRumbleSounds()
        setupView()
        setupZoom()
        registerGestures()
        setText()
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
        
        envelopeMixer = AKMixer.init(envelope)
        
        whiteNoise = AKWhiteNoise(amplitude: 0.3)
        whiteNoiseFilter = AKLowPassFilter.init(whiteNoise, cutoffFrequency: 8000, resonance: 0)
        whiteNoiseMixer = AKMixer.init(whiteNoiseFilter)
        
        masterMixer = AKMixer.init(whiteNoiseMixer, envelopeMixer)
        
        AudioKit.output = masterMixer
        AudioKit.start()
    }
    
    func setupView() {
        rightArrowBtn.setImage(#imageLiteral(resourceName: "Right_Arrow").withRenderingMode(.alwaysTemplate), for: .normal)
        rightArrowBtn.tintColor = .white
        
        rightArrowBtn.accessibilityTraits = UIAccessibilityTraitButton
        
        leftArrowBtn.setImage(#imageLiteral(resourceName: "Left_Arrow").withRenderingMode(.alwaysTemplate), for: .normal)
        leftArrowBtn.tintColor = .white
        
        leftArrowBtn.accessibilityTraits = UIAccessibilityTraitButton
        
        rumbleMapContainer.isAccessibilityElement = true
        rumbleMapContainer.accessibilityLabel = "Start".localized()
        rumbleMapContainer.accessibilityHint = "Double Tap to Start RumbleMap".localized()
        rumbleMapContainer.setAccessibilityAction { 
            self.start()
        }
        
        contactImage.isAccessibilityElement = true
        contactImage.accessibilityTraits |= ~UIAccessibilityTraitAllowsDirectInteraction
        contactImage.accessibilityLabel = "RumbleMap"
        
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.accessibilityTraits = UIAccessibilityTraitHeader // TODO: Add description here
        
        markerContainer = MarkerContainer(frame: contactImage.frame)
    }
    
    func setText() {
        
        rightArrowBtn.accessibilityLabel = "Next".localized()
        rightArrowBtn.accessibilityHint = "Shows the next Eclipse Image".localized()
        
        leftArrowBtn.accessibilityLabel = "Previous".localized()
        leftArrowBtn.accessibilityHint = "Shows the previous Eclipse Image".localized()
        
        titleLabel.text = "Contact Point".localizedFormat(currentIndex+1)
        titleLabel.accessibilityLabel = "Contact Point".localizedFormat(currentIndex+1)
    }
    
    func loadImages() {
        var names = ["Eclipse_1", "Eclipse_2", "Eclipse_3", "Eclipse_4"]
        for i in 0...names.count-1 {
            let eclipseImage = EclipseImage(image: UIImage(named: names[i])!)
            eclipseImages.append(eclipseImage)
        }
        contactImage.image = eclipseImages[currentIndex].image
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextImage(_ sender: Any) {
        currentIndex += 1
        
        if currentIndex > eclipseImages.count-1 {
            currentIndex = 0
        }
        
        contactImage.image = eclipseImages[currentIndex].image
        titleLabel.text = "Contact Point".localizedFormat(currentIndex+1)
        titleLabel.accessibilityLabel = "Contact Point".localizedFormat(currentIndex+1)
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, titleLabel)
    }
    
    @IBAction func previousImage(_ sender: Any) {
        currentIndex -= 1
        
        if currentIndex < 0 {
            currentIndex = eclipseImages.count-1
        }
        
        contactImage.image = eclipseImages[currentIndex].image
        titleLabel.text = "Contact Point".localizedFormat(currentIndex+1)
        titleLabel.accessibilityLabel = "Contact Point".localizedFormat(currentIndex+1)
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.titleLabel)
    }
    
    func registerGestures() {
        contactImage.isUserInteractionEnabled = true
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(self.stop))
        tapGesture1.numberOfTapsRequired = 2
        tapGesture1.numberOfTouchesRequired = 1
        contactImage.addGestureRecognizer(tapGesture1)
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(self.zoomOut))
        tapGesture2.numberOfTapsRequired = 1
        tapGesture2.numberOfTouchesRequired = 2
        rumbleMapContainer.addGestureRecognizer(tapGesture2)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        contactImage.addGestureRecognizer(panGesture)
        
        let touchDownGesture = UILongPressGestureRecognizer(target: self, action: #selector(touchDown(_:)))
        touchDownGesture.minimumPressDuration = 0
        touchDownGesture.delegate = self
        contactImage.addGestureRecognizer(touchDownGesture)
        
        let markerGesture = UILongPressGestureRecognizer(target: self, action: #selector(saveMarkerPosition(_:)))
        markerGesture.minimumPressDuration = 2.0
        markerGesture.allowableMovement = 0.00001
        markerGesture.delegate = self
        rumbleMapContainer.addGestureRecognizer(markerGesture)
    }
    
    func start() {
        print("Started")
        rumbleMapContainer.isAccessibilityElement = false
        rumbleMapContainer.accessibilityTraits |= UIAccessibilityTraitNone
        contactImage.accessibilityTraits |= UIAccessibilityTraitAllowsDirectInteraction
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, contactImage)
    }
    
    func stop () {
        print("Stopped")
        rumbleMapContainer.isAccessibilityElement = true
        rumbleMapContainer.accessibilityTraits |= ~UIAccessibilityTraitNone
        contactImage.accessibilityTraits |= ~UIAccessibilityTraitAllowsDirectInteraction
    }
    
    func zoomOut() {
        if self.scrollView.zoomScale != 1.0 {
            self.scrollView.setZoomScale(1.0, animated: true)
            print("Zoomed Out")
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
            print(location)
            
            if markerContainer.contains(location) {
                print("Over Maker")
            }
            
            if let grayScale = recognizer.view?.grayScale(point: location) {
                //                print(grayScale)
                
                if grayScale == 0.0 {
                    dataGainControl = 0.0
                    whiteNoiseMixer.volume = 0.01
                    whiteNoise.play()
                    whiteNoiseFilter.play()
                    
                } else {
                    
                    whiteNoiseMixer.volume = 0.0
                    
                    dataGainControl = Double(grayScale)
                    modControl = Double(grayScale*modScale)
                    
                    boomBox.play()
                    envelope.play()
                }
            }
            
        } else if recognizer.state == .ended {
            envelope.stop()
            whiteNoiseFilter.stop()
            whiteNoise.stop()
        }
    }
    
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        
        if isZooming {
            return
        }
        
        if recognizer.state == .began || recognizer.state == .changed {
            let location = recognizer.location(in: recognizer.view)
            print(location)
            
            if markerContainer.contains(location) {
                print("Over Maker")
            }
            
            if let grayScale = recognizer.view?.grayScale(point: location) {
                //                print(grayScale)
                
                if grayScale == 0.0 {
                    dataGainControl = 0.0
                    whiteNoiseMixer.volume = 0.01
                    
                    if whiteNoise.isStopped || whiteNoiseFilter.isStopped {
                        whiteNoise.play()
                        whiteNoiseFilter.play()
                    }
                    
                } else {
                    whiteNoiseMixer.volume = 0.0
                    
                    dataGainControl = Double(grayScale)
                    modControl = Double(grayScale*modScale)
                    
                    if boomBox.isStopped || envelope.isStopped {
                        boomBox.play()
                        envelope.play()
                    }
                }
            }
        }
    }
    
    func saveMarkerPosition(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            let location = recognizer.location(in: recognizer.view)
            if !markerContainer.contains(location) {
                markerContainer.insert(location)
                UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, "Marker Placed".localized())
                print("Marker Placed")
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
        whiteNoiseMixer.stop()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        isZooming = false
        
        if scale > zoomScale + 0.1 || scale < zoomScale - 0.1 {
            zoomScale = scale
            let zoomString = "Zoom scale".localizedFormat(zoomScale)
            contactImage.accessibilityValue = zoomString
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

class RumbleMapView : UIView {
    
    var action : (() -> Void)?
    
    func setAccessibilityAction(_ action: @escaping (() -> Void)) {
        self.action = action
    }
    
    override func accessibilityActivate() -> Bool {
        self.action?()
        return true
    }
}

class MarkerContainer : NSObject {
    
    private var container : Dictionary<CGFloat, Dictionary<CGFloat, Bool>>!
    
    init(frame: CGRect) {
        super.init()
        container = Dictionary<CGFloat, Dictionary<CGFloat, Bool>>()
        
        for column in stride(from: 0.0, through: frame.height+1, by: 1.0) {
            var rowDictionary = Dictionary<CGFloat, Bool>()
            for row in stride(from: 0.0, through: frame.width, by: 1.0) {
                rowDictionary.updateValue(false, forKey: row)
            }
            container.updateValue(rowDictionary, forKey: column)
            
        }
    }
    
    func contains(_ point: CGPoint) -> Bool {
        
        guard let column = container[point.y.rounded()], let flag = column[point.x.rounded()] else {
            return false
        }
        return flag
    }
    
    func insert(_ point: CGPoint) {
        
        let negativeY = point.strideDownY()
        let positiveY = point.strideUpY()
        
        let negativeX = point.strideDownX()
        let positiveX = point.strideUpX()
        
        for i in positiveY where container[i] != nil {
            
            var column = container[i]
            for j in positiveX {
                column?.updateValue(true, forKey: j)
            }
            
            for j in negativeX {
                column?.updateValue(true, forKey: j)
            }
        }
        
        for i in negativeY where container[i] != nil {
            var column = container[i]
            for j in positiveX {
                column?.updateValue(true, forKey: j)
            }
            
            for j in negativeX {
                column?.updateValue(true, forKey: j)
            }
        }
    }
    
    func remove(_ point: CGPoint) {
        let negativeY = point.strideDownY()
        let positiveY = point.strideUpY()
        
        let negativeX = point.strideDownX()
        let positiveX = point.strideUpX()
        
        for i in positiveY where container[i] != nil {
            
            var column = container[i]
            for j in positiveX {
                column?.updateValue(false, forKey: j)
            }
            
            for j in negativeX {
                column?.updateValue(false, forKey: j)
            }
        }
        
        for i in negativeY where container[i] != nil {
            var column = container[i]
            for j in positiveX {
                column?.updateValue(false, forKey: j)
            }
            
            for j in negativeX {
                column?.updateValue(false, forKey: j)
            }
        }
    }
    
    override var description: String {
        return self.container.description
    }
    
    subscript(index: CGFloat) -> Dictionary<CGFloat, Bool>? {
        get {
            return container[index]
        }
    }
}
