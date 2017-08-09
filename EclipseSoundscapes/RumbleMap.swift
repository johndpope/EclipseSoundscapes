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
                accessibilityLabel = "Rumble Map Running, Double Tap to turn off"
            } else {
                self.accessibilityTraits = UIAccessibilityTraitNone
                print("Not Active")
                print(self.accessibilityTraits.description)
                accessibilityLabel = "Rumble Map Inactive, Double Tap to turn on"
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

protocol RumbleMapDelegate: class {
    func openIntructions()
}


class RumbleMap : UIView {
    
    deinit {
        print("Destroying Rumble Map")
    }
    
    var event : Event?
    weak var delegate: RumbleMapDelegate?
    
    var rumbleMapImageView: RumbleMapImageView!
    
    var fillerView : UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let closeBtn : SqueezeButton = {
        var btn = SqueezeButton(type: .system)
        btn.addTarget(self, action: #selector(hide), for: .touchUpInside)
        btn.setTitle("Close", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.getDefautlFont(.bold, size: 22)
        btn.backgroundColor = .black
        return btn
    }()
    
    let instructionBtn : SqueezeButton = {
        var btn = SqueezeButton(type: .system)
        btn.addTarget(self, action: #selector(openInstructions), for: .touchUpInside)
        btn.setTitle("Instructions", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.getDefautlFont(.bold, size: 22)
        btn.backgroundColor = .black
        return btn
    }()
    
    let lineSeparatorView1: UIView = {
        let view = UIView()
        view.isAccessibilityElement = false
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()
    
    let lineSeparatorView2: UIView = {
        let view = UIView()
        view.isAccessibilityElement = false
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
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
    
    var markerContainer : MarkerContainer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        rumbleMapImageView = RumbleMapImageView()
        rumbleMapImageView.target =  { [weak self] in
            return self?.fix()
        }
        
        addSubview(rumbleMapImageView)
        addSubview(fillerView)
        addSubview(closeBtn)
        addSubview(instructionBtn)
        addSubview(lineSeparatorView1)
        addSubview(lineSeparatorView2)
        
        
        rumbleMapImageView.anchorToTop(topAnchor, left: leftAnchor, bottom: closeBtn.topAnchor, right: rightAnchor)
        
        fillerView.anchor(closeBtn.topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        closeBtn.anchor(nil, left: leftAnchor, bottom: bottomAnchor, right: centerXAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0.5, widthConstant: 0, heightConstant: 50)
        instructionBtn.anchor(nil, left: centerXAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0.5, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50)
        
        lineSeparatorView1.anchor(nil, left: leftAnchor, bottom: closeBtn.topAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 1)
        lineSeparatorView2.anchor(closeBtn.topAnchor, left: closeBtn.rightAnchor, bottom: bottomAnchor, right: instructionBtn.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        addGestures()
    }
    
    func setSession(active: Bool) {
        stopAudioUnits()
        do {
            if active {
                try AKSettings.setSession(category: .soloAmbient) //TODO: FIX for when audio from the media playing and the user comes here to use the rumble map... Make this take over
                AKSettings.playbackWhileMuted = true
                buildAudioUnits()
                AudioKit.start()
            } else {
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
    
    private func destroyElements() {
        masterMixer = nil
        tickMixer = nil
        markerMixer = nil
        envelopeMixer = nil
        boomBox = nil
        envelope = nil
        tickSound = nil
        markerSound = nil
        
        markerContainer = nil
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
        
        if let event = event {
            markerContainer = MarkerContainer(frame: frame).restore(event)
        }
        
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
        if markerContainer?.contains(location) ?? false {
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
            if !(markerContainer?.contains(location) ?? true) {
                markerContainer?.insert(location)
                
                markerControl = 1.0
                markerSound?.play()
                if let name = event?.name {
                    UserDefaults.standard.set(location.x, forKey: "\(name)rumblePoint-X")
                    UserDefaults.standard.set(location.y, forKey: "\(name)rumblePoint-Y")
                }
                
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
            
            window.accessibilityElements = [rumbleMapImageView, closeBtn, instructionBtn]
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
            self.destroyElements()
            self.closeCompletion?()
            
            self.event = nil
            self.closeCompletion = nil
            self.removeFromSuperview()
        }
    }
    
    func stop() {
        rumbleMapImageView.isActive = false
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, rumbleMapImageView)
    }
    
    func fix() {
        rumbleMapImageView.isActive = false
        
        if closeBtn.accessibilityElementIsFocused() {
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, closeBtn)
        } else {
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, instructionBtn)
        }
        
    }
    
    func makeCancelFocus() {
        envelope?.stop()
        tickSound?.stop()
    }
    
    
    func openInstructions() {
        moveOut(show: false)
        delegate?.openIntructions()
    }
    
    func moveOut(show: Bool) {
        if show {
            self.isAccessibilityElement = true
            UIView.animate(withDuration: 0.2, animations: {
                self.alpha = 1
                
            })
            if let window = UIApplication.shared.keyWindow {
                window.accessibilityElements = [rumbleMapImageView, closeBtn, instructionBtn]
            }
            
        } else {
            if let window = UIApplication.shared.keyWindow {
                window.accessibilityElements = nil
            }
            self.alpha = 0
        }
    }
    
}



extension RumbleMap : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
