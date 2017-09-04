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
import Material
import MediaPlayer

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
    
    var media : Media?
    
    fileprivate var player : TapePlayer?
    
    var progress : Double = 0 {
        didSet {
            controlsContainerView.progress = progress
            
            if media is RealtimeEvent {
                let realtimeMedia = media as! RealtimeEvent
                if realtimeMedia.shouldChangeMedia(for: progress) {
                    realtimeMedia.loadNextMedia(for: progress)
                    DispatchQueue.main.async { [weak self] in
                        if let strongSelf = self {
                            strongSelf.reloadUI()
                        }
                        
                    }
                }
            }
        }
    }
    
    var totalDuration : Double = 0 {
        didSet {
            controlsContainerView.totalDuration = totalDuration
        }
    }
    
    var isRealtimeEvent : Bool = false {
        didSet {
            self.controlsContainerView.pausePlayButton.isHidden = isRealtimeEvent
            self.playerSlider.isUserInteractionEnabled = !isRealtimeEvent
            self.infoTextView.isAccessibilityElement = !isRealtimeEvent
        }
    }
    
    
    var infoControlInfo : [String: Any]!
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func reloadUI() {
        guard let unWrappedMedia = media else {
            return
        }
        
        if let image = unWrappedMedia.image {
            update(artwork: image)
        }
        update(title: unWrappedMedia.name)
        update(progress: self.progress)
        
        controlsContainerView.backgroundImageView.image = unWrappedMedia.image
        titleLabel.text = unWrappedMedia.name
        infoTextView.text = unWrappedMedia.getInfo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(checkViewFocus(notification:)), name: .UIAccessibilityElementFocused, object: nil)
        setupNowPlayingInfoCenter()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        loadMedia()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.stop()
        NotificationCenter.default.removeObserver(self, name: .UIAccessibilityElementFocused, object: nil)
    }
    
    func setupViews() {
        view.backgroundColor = .white
        
        controlsContainerView.setCloseAction(self, action: #selector(close))
        controlsContainerView.setPlayPauseAction(self, action: #selector(playPauseBtnTouched))
        
        view.addSubview(controlsContainerView)
        controlsContainerView.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: view.frame.width * 9 / 16)
        
        view.addSubview(playerSlider)
        
        playerSlider.anchor(nil, left: controlsContainerView.leftAnchor, bottom: controlsContainerView.bottomAnchor, right: controlsContainerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: -15, rightConstant: 0, widthConstant: 0, heightConstant: 30)
        
        view.addSubviews(titleLabel, infoTextView, lineSeparatorView)
        
        titleLabel.anchorWithConstantsToTop(playerSlider.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 10, rightConstant: 0)
        
        lineSeparatorView.anchor(titleLabel.bottomAnchor, left: view.leftAnchor, bottom: infoTextView.topAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 0, heightConstant: 1)
        
        
        infoTextView.anchorWithConstantsToTop(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
    }
    
    func playPauseBtnTouched() {
        guard let playing = player?.isPlaying else {
            handlePlay(play: false)
            return // TODO: Throw Error
        }
        
        handlePlay(play: !playing)
    }
    
    func handlePlay(play : Bool) {
        DispatchQueue.main.async { [weak self] in
            if let strongSelf = self {
                strongSelf.update(progress: strongSelf.progress)
                strongSelf.update(rate: play ? 1 : 0)
                
                if play {
                    strongSelf.player?.play()
                } else {
                    strongSelf.player?.pause()
                }
                strongSelf.updatePlayControl(play: play)
            }
        }
    }
    
    func updatePlayControl(play: Bool){
        controlsContainerView.isPlaying = play
    }
    
    func loadMedia() {
        
        guard let unWrappedMedia = media else {
            return //TODO: Inform user that is failed and they should press something to retry
        }
        
        do {
            player = try TapePlayer.loadTape(withName: unWrappedMedia.resourceName, withExtension: unWrappedMedia.mediaType)
            player!.delegate = self
            
            let duration = player!.duration
            
            infoControlInfo = [String: Any]()
            
            infoControlInfo.updateValue(unWrappedMedia.name, forKey: MPMediaItemPropertyTitle)
            infoControlInfo.updateValue(duration, forKey: MPMediaItemPropertyPlaybackDuration)
            infoControlInfo.updateValue(Double(0), forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime)
            infoControlInfo.updateValue(Double(1), forKey: MPNowPlayingInfoPropertyPlaybackRate)
            
            if let image = unWrappedMedia.image {
                self.controlsContainerView.backgroundImageView.image = image
                infoControlInfo.updateValue(getNowPlayingInfoCenterArtwork(with: image), forKey: MPMediaItemPropertyArtwork)
            }
            
            self.titleLabel.text = unWrappedMedia.name
            self.infoTextView.text = unWrappedMedia.getInfo()
            self.totalDuration = duration
            self.playerSlider.maximumValue = Float(duration)
            
            self.setupNowPlayingInfoCenter(with: infoControlInfo)
            
            handlePlay(play: true)
        } catch  {
            print("Error: \(error)")
            //TODO: Inform user that is failed and they should press something to retry
        }
    }
    
    func checkViewFocus(notification : Notification) {
        if let view = notification.userInfo?[UIAccessibilityFocusedElementKey] as? UIView {
            if view == infoTextView {
                
                guard let playing = player?.isPlaying else {
                    return
                }
                
                if playing {
                    handlePlay(play: false)
                    shouldPlayAgain = true
                    
                }
            }
        }
        if let view = notification.userInfo?[UIAccessibilityUnfocusedElementKey] as? UIView {
            if view == infoTextView {
                
                guard let playing = player?.isPlaying else {
                    return
                }
                if !playing && shouldPlayAgain {
                    handlePlay(play: true)
                    shouldPlayAgain = false
                    
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func close() {
        self.dismiss(animated: true) {
            self.player = nil
            self.resignRemoteCommandCenter()
            self.resignInfoCenter()
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    var shouldPlayAgain : Bool = false
    
    func sliderTouchDown(){
        self.playerSlider.expand()
        guard let playing = player?.isPlaying else {
            return
        }
        if playing {
            handlePlay(play: false)
            shouldPlayAgain = true
        }
    }
    
    func sliderChanged(_ sender: UISlider) {
        skipTo(Double(sender.value))
    }
    
    func sliderTouchUp() {
        self.playerSlider.compress()
        guard let playing = player?.isPlaying else {
            return
        }
        if !playing && shouldPlayAgain  {
            handlePlay(play: true)
            shouldPlayAgain = false
        }
    }
    
    func skipTo(_ time: Double){
        self.progress = time
        self.player?.changeTime(to: self.progress)
        self.update(progress: time)
    }
    
    func remoteSliderSkip(_ time: Double){
        self.update(rate: 0)
        skipTo(time)
        self.update(rate: 1)
    }
    
    
    fileprivate func setupNowPlayingInfoCenter() {
        
        if !isRealtimeEvent {
            
            MPRemoteCommandCenter.shared().playCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus  in
                if let strongSelf = self {
                    strongSelf.handlePlay(play: true)
                    return MPRemoteCommandHandlerStatus.success
                }
                return MPRemoteCommandHandlerStatus.noSuchContent
            }
            MPRemoteCommandCenter.shared().pauseCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus  in
                if let strongSelf = self {
                    strongSelf.handlePlay(play: false)
                    return MPRemoteCommandHandlerStatus.success
                }
                return MPRemoteCommandHandlerStatus.noSuchContent
            }
            
            MPRemoteCommandCenter.shared().togglePlayPauseCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
                if let strongSelf = self {
                    strongSelf.playPauseBtnTouched()
                    return MPRemoteCommandHandlerStatus.success
                }
                return MPRemoteCommandHandlerStatus.noSuchContent
            }
            
            
            if #available(iOS 9.1, *) {
                MPRemoteCommandCenter.shared().changePlaybackPositionCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus  in
                    if let strongSelf = self {
                        if let positionEvent = event as? MPChangePlaybackPositionCommandEvent {
                            strongSelf.remoteSliderSkip(positionEvent.positionTime)
                        }
                        return MPRemoteCommandHandlerStatus.success
                    }
                    return MPRemoteCommandHandlerStatus.noSuchContent
                }
            }
        }
        
    }
    
    private func resignRemoteCommandCenter() {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.removeTarget(self)
        center.pauseCommand.removeTarget(self)
        center.togglePlayPauseCommand.removeTarget(self)
        if #available(iOS 9.1, *) {
            center.changePlaybackPositionCommand.removeTarget(self)
        }
    }
    
    func setupNowPlayingInfoCenter(with info: [String: Any]) {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    func update(title: String){
        self.updateNowPlayingInfoCenter(key: MPMediaItemPropertyTitle, value: title)
    }
    
    func update(rate: Double) {
        self.updateNowPlayingInfoCenter(key: MPNowPlayingInfoPropertyPlaybackRate, value: rate)
    }
    
    func update(progress: Double){
        self.updateNowPlayingInfoCenter(key: MPNowPlayingInfoPropertyElapsedPlaybackTime, value: progress)
    }
    
    func update(artwork: UIImage) {
        self.updateNowPlayingInfoCenter(key: MPMediaItemPropertyArtwork, value: getNowPlayingInfoCenterArtwork(with: artwork))
    }
    
    private func updateNowPlayingInfoCenter(key: String, value: Any) {
        infoControlInfo.updateValue(value, forKey: key)
        DispatchQueue.main.async { [weak self] in
            MPNowPlayingInfoCenter.default().nowPlayingInfo = self?.infoControlInfo
        }
    }
    
    private func resignInfoCenter() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    private func getNowPlayingInfoCenterArtwork(with image : UIImage) -> MPMediaItemArtwork {
        
        let mediaArt : MPMediaItemArtwork!
        if #available(iOS 10.0, *) {
            let mySize = CGSize(width: 400, height: 400)
            mediaArt = MPMediaItemArtwork(boundsSize:mySize) { sz in
                return image.resizeImage(to: sz)
            }
        } else {
            mediaArt = MPMediaItemArtwork.init(image: image)
        }
        
        return mediaArt
    }
}

extension PlaybackViewController : PlayerDelegate {
    
    func progress(_ progress: Double) {
        self.progress = progress
        self.playerSlider.setValue(Float(progress), animated: true)
    }
    
    func finished() {
        print("Player Finished")
        updatePlayControl(play: false)
        self.skipTo(0.0)
        self.playerSlider.setValue(0.0, animated: true)
        self.update(progress: 0)
        if isRealtimeEvent {
            isRealtimeEvent = false
            close()
        }
    }
    func interrupted() {
        print("Player Interrupted")
        controlsContainerView.showControls(true)
        controlsContainerView.pausePlayButton.setImage(#imageLiteral(resourceName: "play").withRenderingMode(.alwaysTemplate), for: UIControlState())
    }
    func resumed() {
        print("Player Resumed")
        guard let playing = player?.isPlaying else {
            return
        }
        
        if playing {
            controlsContainerView.showControls(false)
            controlsContainerView.pausePlayButton.setImage(#imageLiteral(resourceName: "pause").withRenderingMode(.alwaysTemplate), for: UIControlState())
        }
    }
}
