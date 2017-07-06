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

class RumbleMapViewController: UIViewController {
    
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rumbleMap: RumbleMap!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var rightArrowBtn: UIButton!
    @IBOutlet weak var leftArrowBtn: UIButton!
    
    var eclipseImages = [UIImage]()
    var currentIndex = 0
    
    var boomBox : AKFMOscillator!
    var envelope : AKAmplitudeEnvelope!
    var envelopeMixer : AKMixer!
    
    var tickSound : AKAudioPlayer!
    var tickMixer : AKMixer!
    
    var markerSound : AKAudioPlayer!
    var markerMixer : AKMixer!
    
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
    
    var tickControl : Double = 0.0 {
        didSet {
            self.tickMixer.volume = self.tickControl
        }
    }
    
    var markerControl : Double = 0.0 {
        didSet {
            self.markerMixer.volume = self.markerControl
        }
    }
    
    var modScale : CGFloat = 6
    
    var isZooming = false
    var zoomScale : CGFloat = 1.0
    
    var markerContainer : MarkerContainer!
    
    var markerContainers = [MarkerContainer]()
    
    var stopGesture : UITapGestureRecognizer?
    
    var isSessionActive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupView()
        setupZoom()
        registerGestures()
        setAccessibleViews()
        loadImages()
        setText()
        
        titleLabel.adjustsFontSizeToFitWidth = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(voiceOverStatuschaned), name: NSNotification.Name(rawValue: UIAccessibilityVoiceOverStatusChanged), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        
        setSession(active: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isSessionActive {
            setSession(active: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isSessionActive {
            setSession(active: false)
        }
    }
    
    func setText() {
        titleLabel.font = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(fontName: .bold, textStyle: .headline), size: 0)
    }
    
    func setSession(active: Bool) {
        
        do {
            if active {
                try AKSettings.setSession(category: .playback)
                try AKSettings.session.setActive(true, with: .notifyOthersOnDeactivation)
                AKSettings.playbackWhileMuted = true
                setupRumbleSounds()
                AudioKit.start()
                isSessionActive = true
            } else {
                stopRumbleSound()
                AudioKit.stop()
                try AKSettings.session.setActive(false)
                isSessionActive = false
            }
            
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func setupRumbleSounds() {
        boomBox = AKFMOscillator(waveform: AKTable.init(), baseFrequency: 55, carrierMultiplier: 4, modulatingMultiplier: 1, modulationIndex: 1, amplitude: 1)
        
        boomBox.rampTime = 0.01
        
        envelope = AKAmplitudeEnvelope(boomBox, attackDuration: 1.0, decayDuration: 0.1, sustainLevel: 1.0, releaseDuration: 0.1)
        
        envelopeMixer = AKMixer.init(envelope)
        
        let tickFile = try! AKAudioFile(forReading: Bundle.main.url(forResource: "xytick", withExtension: ".wav")!)
        tickSound = try! AKAudioPlayer(file: tickFile, looping: true, completionHandler: {
            self.tickControl = 0.0
        })
        
        tickMixer = AKMixer.init(tickSound)
        
        let markerFile = try! AKAudioFile(forReading: Bundle.main.url(forResource: "mapmarker", withExtension: ".wav")!)
        markerSound = try! AKAudioPlayer(file: markerFile, looping: false, completionHandler: {
            self.markerControl = 0.0
        })
        markerMixer = AKMixer.init(markerSound)
        
        masterMixer = AKMixer.init(markerMixer, tickMixer, envelopeMixer)
        
        AudioKit.output = masterMixer
    }
    
    func stopRumbleSound() {
        masterMixer.stop()
        tickMixer.stop()
        markerMixer.stop()
        envelopeMixer.stop()
        boomBox.stop()
        envelope.stop()
        tickSound.stop()
        markerSound.stop()
    }
    
    func setupView() {
        
        rightArrowBtn.setImage(#imageLiteral(resourceName: "Right_Arrow").withRenderingMode(.alwaysTemplate), for: .normal)
        rightArrowBtn.tintColor = .white
        
        leftArrowBtn.setImage(#imageLiteral(resourceName: "Left_Arrow").withRenderingMode(.alwaysTemplate), for: .normal)
        leftArrowBtn.tintColor = .white
        
        titleLabel.adjustsFontSizeToFitWidth = true
    }
    
    func setAccessibleViews() {
        
        rightArrowBtn.accessibilityLabel = "Next".localized()
        rightArrowBtn.accessibilityHint = "Shows the next Eclipse Image".localized()
        rightArrowBtn.accessibilityTraits = UIAccessibilityTraitButton
        
        leftArrowBtn.accessibilityLabel = "Previous".localized()
        leftArrowBtn.accessibilityHint = "Shows the previous Eclipse Image".localized()
        leftArrowBtn.accessibilityTraits = UIAccessibilityTraitButton
        
        titleLabel.text = "Contact Point".localizedFormat(currentIndex+1)
        titleLabel.accessibilityLabel = "Contact Point".localizedFormat(currentIndex+1)
        titleLabel.accessibilityTraits = UIAccessibilityTraitHeader // TODO: Add description here
        
        scrollView.isAccessibilityElement = false
        scrollView.accessibilityElements = [rumbleMap]
        
        rumbleMap.isAccessibilityElement = true
        rumbleMap.accessibilityLabel = "Rumble Map"
        rumbleMap.accessibilityHint = "Double Tap to Start"
        rumbleMap.accessibilityTraits = UIAccessibilityTraitNone
    }
    
    func loadImages() {
        var names = ["Eclipse_1", "Eclipse_2", "Eclipse_3", "Eclipse_4"]
        for i in 0...names.count-1 {
            eclipseImages.append(UIImage(named: names[i])!)
            markerContainers.append(MarkerContainer(frame: rumbleMap.frame).restore(forIndex: i))
        }
        rumbleMap.image = eclipseImages[currentIndex]
        markerContainer = markerContainers[currentIndex]
    }
    
    func setupZoom() {
        
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.flashScrollIndicators()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        scrollView.canCancelContentTouches = false
        scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
        scrollView.clipsToBounds = true
    }
    
    func registerGestures() {
        rumbleMap.isUserInteractionEnabled = true
        
        let stopGesture = UITapGestureRecognizer(target: self, action: #selector(self.stop))
        stopGesture.numberOfTapsRequired = 2
        stopGesture.numberOfTouchesRequired = 1
        rumbleMap.addGestureRecognizer(stopGesture)
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(self.zoomOut))
        tapGesture2.numberOfTapsRequired = 1
        tapGesture2.numberOfTouchesRequired = 2
        rumbleMap.addGestureRecognizer(tapGesture2)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        rumbleMap.addGestureRecognizer(panGesture)
        
        let touchDownGesture = UILongPressGestureRecognizer(target: self, action: #selector(touchDown(_:)))
        touchDownGesture.minimumPressDuration = 0
        touchDownGesture.delegate = self
        rumbleMap.addGestureRecognizer(touchDownGesture)
        
        let markerGesture = UILongPressGestureRecognizer(target: self, action: #selector(saveMarkerPosition(_:)))
        markerGesture.delegate = self
        markerGesture.minimumPressDuration = 2.0
        rumbleMap.addGestureRecognizer(markerGesture)
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
        
        markerContainer = markerContainers[currentIndex]
        rumbleMap.image = eclipseImages[currentIndex]
        titleLabel.text = "Contact Point".localizedFormat(currentIndex+1)
        titleLabel.accessibilityLabel = "Contact Point".localizedFormat(currentIndex+1)
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, titleLabel)
        zoomOut()
    }
    
    @IBAction func previousImage(_ sender: Any) {
        currentIndex -= 1
        
        if currentIndex < 0 {
            currentIndex = eclipseImages.count-1
        }
        
        markerContainer = markerContainers[currentIndex]
        rumbleMap.image = eclipseImages[currentIndex]
        titleLabel.text = "Contact Point".localizedFormat(currentIndex+1)
        titleLabel.accessibilityLabel = "Contact Point".localizedFormat(currentIndex+1)
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.titleLabel)
        zoomOut()
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
            if !(recognizer.view?.frame.contains(location))! {
                envelope.stop()
                tickSound.stop()
                return
            }
            playSound(forLocation: location)
            
        } else if recognizer.state == .ended {
            envelope.stop()
            tickSound.stop()
        }
    }
    
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        
        if isZooming {
            envelope.stop()
            tickSound.stop()
            return
        }
        
        if recognizer.state == .began || recognizer.state == .changed {
            let location = recognizer.location(in: recognizer.view)
            print(location)
            if !(recognizer.view?.frame.contains(location))! {
                envelope.stop()
                tickSound.stop()
                return
            }
            playSound(forLocation: location)
        } else if recognizer.state == .ended {
            envelope.stop()
            tickSound.stop()
        }
    }
    
    func playSound(forLocation location : CGPoint) {
        if markerContainer.contains(location) {
            markerControl = 1.0
            if !markerSound.isPlaying {
                markerSound.play()
            }
            print("Over Maker")
        } else {
            markerSound.stop()
        }
        
        let grayScale = rumbleMap.grayScale(point: location)
        
        if grayScale == 0.0 {
            dataGainControl = 0.0
            modControl = 0.00
            
            tickControl = 0.8
            if !tickSound.isPlaying {
                tickSound.play()
            }
            
        } else {
            tickControl = 0.0
            
            dataGainControl = Double(grayScale)
            modControl = Double(grayScale*modScale)
            
            if boomBox.isStopped || envelope.isStopped {
                boomBox.play()
                envelope.play()
            }
        }
        
    }
    
    func saveMarkerPosition(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            let location = recognizer.location(in: recognizer.view)
            if !markerContainer.contains(location) {
                markerContainer.insert(location)
                
                markerControl = 1.0
                markerSound.play()
                print("Marker Placed at \(location.debugDescription)")
                UserDefaults.standard.set(location.x, forKey: "\(currentIndex)rumblePoint-X")
                UserDefaults.standard.set(location.y, forKey: "\(currentIndex)rumblePoint-Y")
                
            }
        }
    }
    
    func stop() {
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, rumbleMap)
        rumbleMap.isActive = false
    }
    
    func voiceOverStatuschaned() {
        if UIAccessibilityIsVoiceOverRunning() {
            stopGesture = UITapGestureRecognizer(target: self, action: #selector(self.stop))
            stopGesture?.numberOfTapsRequired = 2
            stopGesture?.numberOfTouchesRequired = 1
            rumbleMap.addGestureRecognizer(stopGesture!)
        } else {
            if stopGesture != nil {
                rumbleMap.removeGestureRecognizer(stopGesture!)
                rumbleMap.isActive = false
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension RumbleMapViewController : UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.rumbleMap
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        isZooming = true
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        isZooming = false
        
        if scale > zoomScale + 0.1 || scale < zoomScale - 0.1 {
            zoomScale = scale
            let zoomString = "Zoom scale".localizedFormat(zoomScale)
            rumbleMap.accessibilityValue = zoomString
        }
    }
}

extension RumbleMapViewController : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
