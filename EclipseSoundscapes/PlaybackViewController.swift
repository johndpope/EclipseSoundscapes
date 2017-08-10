//
//  PlaybackViewController.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 6/13/17.
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

class PlaybackViewController: UIViewController {
    
    let controlsContainerView: MediaControlView = {
        let view = MediaControlView()
        view.backgroundColor = .black
        return view
    }()
    
    lazy var playerSlider: MediaSlider = {
        let slider = MediaSlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumTrackTintColor = Color.eclipseOrange
        slider.setThumbImage(#imageLiteral(resourceName: "Eclipse-thumb"), for: UIControlState())
        
        slider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderTouchDown), for: .touchDown)
        slider.addTarget(self, action: #selector(sliderTouchUp), for: [.touchUpInside, .touchUpOutside])
        
        return slider
    }()
    
    var titleLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.getDefautlFont(.bold, size: 20)
        label.accessibilityTraits = UIAccessibilityTraitHeader
        label.numberOfLines = 0
        return label
    }()
    
    var infoTextView : UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textAlignment = .left
        tv.font = UIFont.getDefautlFont(.meduium, size: 17)
        tv.accessibilityTraits = UIAccessibilityTraitStaticText
        tv.isEditable = false
        tv.textContainerInset = UIEdgeInsetsMake(20, 20, 10, 20)
        tv.backgroundColor = UIColor(r: 249, g: 249, b: 249)
        return tv
    }()
    
    let lineSeparatorView: UIView = {
        let view = UIView()
        view.isAccessibilityElement = false
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()
    
    var media : Media!
    
    var isPlaying = false {
        didSet {
            controlsContainerView.isPlaying = isPlaying
        }
    }
    
    fileprivate var player : TapePlayer!
    
    var progress : Double = 0 {
        didSet {
            controlsContainerView.progress = progress
            
            if media is RealtimeEvent {
                
                let realtimeMedia = media as! RealtimeEvent
                if realtimeMedia.shouldChangeMedia(for: progress) {
                    realtimeMedia.loadNextMedia(for: progress)
                    DispatchQueue.main.async {
                        self.controlsContainerView.backgroundImageView.image = realtimeMedia.image
                        self.titleLabel.text = realtimeMedia.name
                        self.infoTextView.text = realtimeMedia.getInfo()
                    }
                }
            }
        }
    }
    
    var isRealtimeEvent : Bool = false {
        didSet {
            self.controlsContainerView.pausePlayButton.isHidden = isRealtimeEvent
            self.playerSlider.isUserInteractionEnabled = !isRealtimeEvent
            self.infoTextView.isAccessibilityElement = !isRealtimeEvent
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        controlsContainerView.setCloseAction(self, action: #selector(close))
        controlsContainerView.setPlayPauseAction(self, action: #selector(playPauseBtnTouched))
        
        view.addSubview(controlsContainerView)
        controlsContainerView.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: view.frame.width * 9 / 16)
        
        view.addSubview(playerSlider)
        
        playerSlider.anchor(nil, left: controlsContainerView.leftAnchor, bottom: controlsContainerView.bottomAnchor, right: controlsContainerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: -15, rightConstant: 0, widthConstant: 0, heightConstant: 30)
        
        view.addSubview(titleLabel)
        view.addSubview(infoTextView)
        view.addSubview(lineSeparatorView)
        
        titleLabel.anchorWithConstantsToTop(playerSlider.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 10, rightConstant: 0)
        
        lineSeparatorView.anchor(titleLabel.bottomAnchor, left: view.leftAnchor, bottom: infoTextView.topAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 0, heightConstant: 1)
        
        
        infoTextView.anchorWithConstantsToTop(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
        
        view.backgroundColor = .white
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkViewFocus(notification:)), name: Notification.Name.UIAccessibilityElementFocused, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, controlsContainerView)
        loadMedia()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.player.stop(.finished)
        NotificationCenter.default.removeObserver(self)
    }
    
    func playPauseBtnTouched() {
        handlePlay(play: !isPlaying)
    }
    
    func handlePlay(play : Bool) {
        isPlaying = play
        if play {
            controlsContainerView.showControls(false)
            player.play()
            controlsContainerView.pausePlayButton.setImage(#imageLiteral(resourceName: "pause").withRenderingMode(.alwaysTemplate), for: UIControlState())
        } else {
            controlsContainerView.showControls(true)
            player.pause()
            controlsContainerView.pausePlayButton.setImage(#imageLiteral(resourceName: "play").withRenderingMode(.alwaysTemplate), for: UIControlState())
        }
    }
    
    func loadMedia() {
        
        self.controlsContainerView.backgroundImageView.image = media.image
        self.titleLabel.text = media.name
        self.infoTextView.text = media.getInfo()
        
        if let tape = AudioManager.loadAudio(withName: media.resourceName, withExtension: media.mediaType){
            loadTape(tape: tape)
        }
    }
    
    
    func loadTape(tape: Tape) {
        self.player = TapePlayer(tape: tape)
        self.player.delegate = self
        controlsContainerView.totalDuration = player.duration
        playerSlider.maximumValue = Float(player.duration)
        handlePlay(play: true)
    }
    
    func checkViewFocus(notification : Notification) {
        if let view = notification.userInfo?[UIAccessibilityFocusedElementKey] as? UIView {
            if view == infoTextView {
                handlePlay(play: false)
            }
        }
        if let view = notification.userInfo?[UIAccessibilityUnfocusedElementKey] as? UIView {
            if view == infoTextView {
                handlePlay(play: true)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sliderTouchDown(){
        handlePlay(play: false)
    }
    
    func sliderTouchUp() {
        handlePlay(play: false)
    }
    
    func sliderChanged(_ sender: UISlider) {
        self.progress = Double(sender.value)
        self.player.changeTime(to: progress)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
extension PlaybackViewController : PlayerDelegate {
    func canceled() {
        print("Player Closed")
    }

    func progress(_ progress: Double) {
        self.progress = progress
        self.playerSlider.setValue(Float(progress), animated: true)
    }
    func finished() {
        print("Player Finished")
        self.handlePlay(play: false)
        self.progress = 0.0
        self.player.changeTime(to: progress)
        self.playerSlider.setValue(Float(progress), animated: false)
        if isRealtimeEvent {
            isRealtimeEvent = false
            close()
        }
    }
    func paused() {
        print("Player Paused")
    }
    func resumed() {
        print("Player Resumed")
    }
}
