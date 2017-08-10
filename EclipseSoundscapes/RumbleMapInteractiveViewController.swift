//
//  RumbleMapInteractiveViewController.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 8/8/17.
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

class RumbleMapInteractiveViewController: UIViewController {
    
    var event : Event? {
        didSet {
            self.rumbleMapImageView.image = event?.image
        }
    }
    
    var rumbleMapImageView =  RumbleMapImageView()
    
    let closeBtn : SqueezeButton = {
        var btn = SqueezeButton(type: .system)
        btn.addTarget(self, action: #selector(close), for: .touchUpInside)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(returnToApplication), name: .UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(leftApplication), name: .UIApplicationWillResignActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceConnectedNotification), name: Notification.Name.AVAudioSessionRouteChange, object: nil)
        // add interruption handler
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(_:)), name: NSNotification.Name.AVAudioSessionInterruption, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setSession(active: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setSession(active: false)
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupView() {
        rumbleMapImageView.target =  { [weak self] in
            return self?.fix()
        }
        
        view.addSubview(rumbleMapImageView)
        view.addSubview(closeBtn)
        view.addSubview(instructionBtn)
        view.addSubview(lineSeparatorView1)
        view.addSubview(lineSeparatorView2)
        
        rumbleMapImageView.anchorToTop(view.topAnchor, left: view.leftAnchor, bottom: closeBtn.topAnchor, right: view.rightAnchor)
    
        closeBtn.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.centerXAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0.5, widthConstant: 0, heightConstant: 50)
        instructionBtn.anchor(nil, left: view.centerXAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0.5, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50)
        
        lineSeparatorView1.anchor(nil, left: view.leftAnchor, bottom: closeBtn.topAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 1)
        lineSeparatorView2.anchor(closeBtn.topAnchor, left: closeBtn.rightAnchor, bottom: view.bottomAnchor, right: instructionBtn.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        addGestures()
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
            markerContainer = MarkerContainer(frame: view.frame).restore(event)
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
    
    func makeCancelFocus() {
        envelope?.stop()
        tickSound?.stop()
    }
    
    func close() {
        self.dismiss(animated: true, completion: nil)
    }

    func openInstructions() {
        self.present(IntructionsViewController(), animated: true, completion: nil)
    }
    
    //MARK: Notification Handlers
    
    func returnToApplication(){
        setSession(active: true)//Returned
        
    }
    
    func leftApplication() {
        setSession(active: false)//Left
    }
    
    
    /// Notification handler for AVAudioSessionRouteChange to catch changes to device connection from the audio jack.
    ///
    /// - Parameter notification: Notification object cointaing AVAudioSessionRouteChange data
    func deviceConnectedNotification(notification: Notification){
        
        let audioRouteChangeReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt
        switch audioRouteChangeReason {
        case AVAudioSessionRouteChangeReason.newDeviceAvailable.rawValue: ///device is connected
            setSession(active: true)
            break
            
        case AVAudioSessionRouteChangeReason.oldDeviceUnavailable.rawValue: ///device is not connected
            
            setSession(active: true)
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
        //TODO: Stop RumbleMap, but rotation is prohibited now
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }

}

extension RumbleMapInteractiveViewController : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
