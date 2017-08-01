//
//  RumbleView.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 7/5/17.
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

class RumbleMapImageView : UIImageView {
    
    init(){
        super.init(frame: .zero)
        isAccessibilityElement = true
        isUserInteractionEnabled = true
        backgroundColor = .black
        contentMode = .scaleAspectFit
        accessibilityTraits = UIAccessibilityTraitNone
        accessibilityLabel = "Rumble Map Inactive Double Tap to turn on"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var isActive = false {
        didSet {
            if isActive {
                self.accessibilityTraits |= UIAccessibilityTraitAllowsDirectInteraction
                print("Became Active")
                print(self.accessibilityTraits.description)
                accessibilityLabel = "Rumble Map Running"
                accessibilityHint = "Double Tap to turn off"
            } else {
                self.accessibilityTraits = UIAccessibilityTraitNone
                print("Not Active")
                print(self.accessibilityTraits.description)
                accessibilityLabel = "Rumble Map Inactive"
                accessibilityHint = "Double Tap to turn on"
            }
        }
    }
    
    override func accessibilityActivate() -> Bool {
        self.isActive = true
        return true
    }
    
    override func accessibilityElementDidLoseFocus() {
        target?()
    }
    
    var target : (()->Void)?
}


class RumbleMap : UIView {
    
    var event : Event!
    
    var rumbleMapImageView: RumbleMapImageView!
    var closeBtn: SqueezeButton!
    
    let lineSeparatorView: UIView = {
        let view = UIView()
        view.isAccessibilityElement = false
        view.backgroundColor = UIColor(white: 0.9, alpha: 1)
        return view
    }()
    
    var boomBox : AKFMOscillator?
    var envelope : AKAmplitudeEnvelope?
    var envelopeMixer : AKMixer?
    
    var tickSound : AKAudioPlayer?
    var tickMixer : AKMixer?
    
    var markerSound : AKAudioPlayer?
    var markerMixer : AKMixer?
    
    var masterMixer : AKMixer?
    
    var closeCompletion : (()->Void)?
    
    var dataGainControl : Double = 0.0 {
        didSet {
            self.envelopeMixer?.volume = self.dataGainControl
        }
    }
    
    var modControl : Double = 1.0 {
        didSet {
            if modControl < 1 {
                modControl += 1
            }
            self.boomBox?.modulatingMultiplier = modControl
        }
    }
    
    var tickControl : Double = 0.0 {
        didSet {
            self.tickMixer?.volume = self.tickControl
        }
    }
    
    var markerControl : Double = 0.0 {
        didSet {
            self.markerMixer?.volume = self.markerControl
        }
    }
    
    var modScale : CGFloat = 6
    
    var markerContainer : MarkerContainer!
    
    var markerContainers = [MarkerContainer]()
    
    deinit {
        setSession(active: false)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeView()
    }
    
    
    func initializeView() {

        rumbleMapImageView = RumbleMapImageView()
        rumbleMapImageView.target =  {
            return self.fix()
        }
    
        closeBtn = SqueezeButton(type: .system)
        closeBtn.addTarget(self, action: #selector(hide), for: .touchUpInside)
        closeBtn.setTitle("Close", for: .normal)
        closeBtn.setTitleColor(.white, for: .normal)
        closeBtn.titleLabel?.font = UIFont.getDefautlFont(.bold, size: 22)
        closeBtn.backgroundColor = .black
        
        layoutViews()
        addGestures()
    }
    
    func layoutViews() {
        addSubview(rumbleMapImageView)
        addSubview(closeBtn)
        rumbleMapImageView.anchorToTop(topAnchor, left: leftAnchor, bottom: closeBtn.topAnchor, right: rightAnchor)
        closeBtn.anchor(nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50)
        
        
    }
    
    func setSession(active: Bool) {
        stopAudioUnits()
        
        do {
            if active {
                try AKSettings.setSession(category: .soloAmbient)
                AKSettings.playbackWhileMuted = true
                buildAudioUnits()
                AudioKit.start()
            } else {
                stopAudioUnits()
                AudioKit.stop()
                try AKSettings.session.setActive(false)
            }
            
        } catch {
            print("Error: \(error.localizedDescription)")
            let banner = Banner(title: "Something Bad Happened", subtitle: "Press to try again", didTapBlock: {
                self.setSession(active: true)
            })
            banner.show()
        }
    }
    
    func willRotate() {
        envelope?.stop()
        tickSound?.stop()
        self.layoutViews()
    }
    
    private func stopAudioUnits() {
        masterMixer?.stop()
        tickMixer?.stop()
        markerMixer?.stop()
        envelopeMixer?.stop()
        boomBox?.stop()
        envelope?.stop()
        tickSound?.stop()
        markerSound?.stop()
    }

    
    func addGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        rumbleMapImageView.addGestureRecognizer(panGesture)
        
        let touchDownGesture = UILongPressGestureRecognizer(target: self, action: #selector(touchDown(_:)))
        touchDownGesture.minimumPressDuration = 0
        touchDownGesture.delegate = self
        rumbleMapImageView.addGestureRecognizer(touchDownGesture)
        
        let markerGesture = UILongPressGestureRecognizer(target: self, action: #selector(saveMarkerPosition(_:)))
        markerGesture.minimumPressDuration = 1.5
        markerGesture.delegate = self
        rumbleMapImageView.addGestureRecognizer(markerGesture)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(stop))
        doubleTap.numberOfTapsRequired = 2
        rumbleMapImageView.addGestureRecognizer(doubleTap)
    }
    
    func buildAudioUnits() {
        boomBox = AKFMOscillator(waveform: AKTable.init(), baseFrequency: 55, carrierMultiplier: 4, modulatingMultiplier: 1, modulationIndex: 1, amplitude: 1)
        
        boomBox?.rampTime = 0.01
        
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
        
        
        markerContainer = MarkerContainer(frame: frame).restore(self.event)
        
        AudioKit.output = masterMixer
    }
    
    func touchDown(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.numberOfTouches > 2 {
            envelope?.stop()
            tickSound?.stop()
            return
        }
        if recognizer.state == .began {
            let location = recognizer.location(in: recognizer.view)
            if !(recognizer.view?.frame.contains(location))! {
                makeCancelFocus()
                return
            }
            playSound(forLocation: location)
            
        } else if recognizer.state == .ended {
            envelope?.stop()
            tickSound?.stop()
        }
    }
    
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        
        if recognizer.state == .began || recognizer.state == .changed {
            let location = recognizer.location(in: recognizer.view)
            if !(recognizer.view?.frame.contains(location))! {
                makeCancelFocus()
                return
            }
            playSound(forLocation: location)
        } else if recognizer.state == .ended {
            envelope?.stop()
            tickSound?.stop()
        }
    }
    
    func playSound(forLocation location : CGPoint) {
        if markerContainer.contains(location) {
            markerControl = 1.0
            if !(markerSound?.isPlaying ?? true) {
                markerSound?.play()
            }
        } else {
            markerSound?.stop()
        }
        
        let grayScale = rumbleMapImageView.grayScale(point: location)
        
        if grayScale == 0.0 {
            dataGainControl = 0.0
            modControl = 0.00
            
            tickControl = 0.8
            if !(tickSound?.isPlaying)! {
                tickSound?.play()
            }
            
        } else {
            tickControl = 0.0
            
            dataGainControl = Double(grayScale)
            modControl = Double(grayScale*modScale)
            
            if boomBox?.isStopped ?? false || envelope?.isStopped ?? false {
                boomBox?.play()
                envelope?.play()
            }
        }
        
    }
    
    func saveMarkerPosition(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            let location = recognizer.location(in: recognizer.view)
            if !markerContainer.contains(location) {
                markerContainer.insert(location)
                
                markerControl = 1.0
                markerSound?.play()
                UserDefaults.standard.set(location.x, forKey: "\(event.name)rumblePoint-X")
                UserDefaults.standard.set(location.y, forKey: "\(event.name)rumblePoint-Y")
                
            }
        }
    }
    func show(_ event : Event,_ completion:(()->Void)? = nil) {
        
        self.event = event
        rumbleMapImageView.image = event.image!
        
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(self)
            self.anchorToTop(window.topAnchor, left: window.leftAnchor, bottom: window.bottomAnchor, right: window.rightAnchor)
            self.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
            self.centerYAnchor.constraint(equalTo: window.centerYAnchor).isActive = true
            
            window.accessibilityElements = [rumbleMapImageView, closeBtn]
        }
        
        self.transform = CGAffineTransform.init(scaleX: CGFloat.leastNormalMagnitude, y: CGFloat.leastNormalMagnitude)
        self.alpha = 0
        
        UIView.animate(withDuration: 0.8, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: { 
            self.transform = CGAffineTransform.identity
            self.alpha = 1
        }) { (_) in
            self.setSession(active: true)
            completion?()
            
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.8, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.transform = CGAffineTransform.init(scaleX: 20, y: 20)
            self.alpha = 0
        }) { (_) in
            if let window = UIApplication.shared.keyWindow {
                window.accessibilityElements = nil
            }
            
            self.setSession(active: false)
            self.removeFromSuperview()
            self.closeCompletion?()
        }
    }
    
    func stop() {
        rumbleMapImageView.isActive = false
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, rumbleMapImageView)
    }
    
    func fix() {
        rumbleMapImageView.isActive = false
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, closeBtn)
    }
    
    func makeCancelFocus() {
        envelope?.stop()
        tickSound?.stop()
    }
}

extension RumbleMap : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
