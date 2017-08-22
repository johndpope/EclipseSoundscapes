//
//  RumbleMap.swift
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

class RumbleMap : UIImageView {
    
    var isRestarting = false
    var shouldPlay = true
    
    var event : Event? {
        didSet {
            self.image = event?.image
        }
    }
    
    var boomBox : AKFMOscillator?
    var envelope : AKAmplitudeEnvelope?
    var envelopeMixer : AKMixer?
    
    var tickSound : AKAudioPlayer?
    var tickMixer : AKMixer?
    
    var markerSound : AKAudioPlayer?
    var markerMixer : AKMixer?
    
    var masterMixer : AKMixer?
    
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
    
    // Gesture Recognizers
    private var touchDownGesture : UILongPressGestureRecognizer!
    private var panGesture : UIPanGestureRecognizer!
    private var markerGesture : UILongPressGestureRecognizer!
    private var doubleTap : UITapGestureRecognizer!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    init(){
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        isAccessibilityElement = true
        isUserInteractionEnabled = true
        backgroundColor = .black
        contentMode = .scaleAspectFit
        accessibilityTraits = UIAccessibilityTraitNone
        accessibilityLabel = "Rumble Map Inactive Double Tap to turn on"
        
        addGestures()
        
        NotificationCenter.default.addObserver(self, selector: #selector(returnToApplication), name: .UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(leftApplication), name: .UIApplicationWillResignActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceConnectedNotification), name: Notification.Name.AVAudioSessionRouteChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(_:)), name: NSNotification.Name.AVAudioSessionInterruption, object: nil)
    }
    
    override func accessibilityActivate() -> Bool {
        self.isActive = true
        return true
    }
    
    override func accessibilityElementDidLoseFocus() {
        target?()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let event = event {
            markerContainer = MarkerContainer(frame: frame).restore(event)
        }
    }
    
    var target : (()->Void)?
    
    func addGestures() {
        touchDownGesture = UILongPressGestureRecognizer(target: self, action: #selector(touchDown(_:)))
        touchDownGesture.minimumPressDuration = 0
        touchDownGesture.delegate = self
        self.addGestureRecognizer(touchDownGesture)
        
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        self.addGestureRecognizer(panGesture)
        
        markerGesture = UILongPressGestureRecognizer(target: self, action: #selector(saveMarkerPosition(_:)))
        markerGesture.minimumPressDuration = 1.5
        markerGesture.delegate = self
        self.addGestureRecognizer(markerGesture)
        
        doubleTap = UITapGestureRecognizer(target: self, action: #selector(stop))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
    }
    
    func removeGestures() {
        touchDownGesture.isEnabled = false
        panGesture.isEnabled = false
        markerGesture.isEnabled = false
        doubleTap.isEnabled = false
        
        self.removeGestureRecognizer(touchDownGesture)
        self.removeGestureRecognizer(panGesture)
        self.removeGestureRecognizer(markerGesture)
        self.removeGestureRecognizer(doubleTap)
        
    }
    
    func touchDown(_ recognizer: UILongPressGestureRecognizer) {
        if !AudioKit.engine.isRunning {
            restart()
        }
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
        if !AudioKit.engine.isRunning {
            restart()
        }
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
        
        let grayScale = self.grayScale(point: location)
        
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
    
    
    func setSession(active: Bool) {
        do {
            if active {
                try AKSettings.setSession(category: .soloAmbient) //TODO: FIX for when audio from the media playing and the user comes here to use the rumble map... Make this take over
                AKSettings.playbackWhileMuted = true
                buildAudioUnits()
                AudioKit.start()
            } else {
                stopAudioUnits()
                AudioKit.stop()
            }
            
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func stop() {
        isActive = false
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self)
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
        
        AudioKit.output = masterMixer
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
        destroyAudioUnits()
        
    }
    
    private func destroyAudioUnits() {
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
    
    func makeCancelFocus() {
        envelope?.stop()
        tickSound?.stop()
    }
}

extension RumbleMap : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !isRestarting && shouldPlay
    }
}

extension RumbleMap {
    //MARK: Notification Handlers
    
    func returnToApplication(){
        shouldPlay = true
        setSession(active: true)//Returned
    }
    
    func leftApplication() {
        shouldPlay = false
        setSession(active: false)//Left
    }
    
    
    /// Notification handler for AVAudioSessionRouteChange to catch changes to device connection from the audio jack.
    ///
    /// - Parameter notification: Notification object cointaing AVAudioSessionRouteChange data
    func deviceConnectedNotification(notification: Notification){
        
        let audioRouteChangeReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt
        switch audioRouteChangeReason {
        case AVAudioSessionRouteChangeReason.newDeviceAvailable.rawValue: ///device is connected
            print("Device Connected Engine: \(AudioKit.engine.isRunning)")
            restart()
            break
            
        case AVAudioSessionRouteChangeReason.oldDeviceUnavailable.rawValue: ///device is not connected
            print("No Device Connected Engine: \(AudioKit.engine.isRunning)")
            restart()
            break
            
        default:
            break
        }
    }
    
    func restart() {
        isRestarting = true
        AudioKit.start()
        print("After Restart Engine: \(AudioKit.engine.isRunning)")
        isRestarting = false
    }
    
    //TODO: Implement the recording to pause while interruption is in prpogress and restart after interruption is stoped
    /// Interruption Handler
    ///
    /// - Parameter notification: Device generated notification about interruption
    func handleInterruption(_ notification: Notification) {
        guard let info = notification.userInfo,
            let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSessionInterruptionType(rawValue: typeValue) else {
                return
        }
        if type == .began {
            // Interruption began, take appropriate actions (save state, update user interface)
            
        }
        else if type == .ended {
            guard let optionsValue =
                info[AVAudioSessionInterruptionOptionKey] as? UInt else {
                    return
            }
            let options = AVAudioSessionInterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                // Interruption Ended - playback should resume
                if !AudioKit.engine.isRunning {
                    AudioKit.start()
                }
            }
        }
        
        
    }
    
}
