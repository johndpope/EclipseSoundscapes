//
//  MediaControlView.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 8/6/17.
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

class MediaControlView : UIView {
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var totalDuration : Double = 0 {
        didSet {
            self.totalLengthLabel.text = Utility.timeString(time: totalDuration)
            self.totalLengthLabel.accessibilityLabel = Utility.timeAccessibilityString(time: totalDuration)
        }
    }
    
    var progress : Double = 0 {
        didSet {
            self.currentTimeLabel.text = Utility.timeString(time: progress)
            self.currentTimeLabel.accessibilityLabel = Utility.timeAccessibilityString(time: progress) + " of " + self.totalLengthLabel.accessibilityLabel!
        }
    }
    
    var controlsShowing = true
    var isPlaying = true {
        didSet {
            pausePlayButton.accessibilityLabel = isPlaying ? "Pause" : "Play"
            showControls(!isPlaying)
            if isPlaying {
                pausePlayButton.setImage(#imageLiteral(resourceName: "pause").withRenderingMode(.alwaysTemplate), for: UIControlState())
            } else {
                pausePlayButton.setImage(#imageLiteral(resourceName: "play").withRenderingMode(.alwaysTemplate), for: UIControlState())
            }
        }
    }
    
    
    lazy var pausePlayButton: UIButton = {
        var btn = UIButton(type: .system)
        btn.addSqueeze()
        btn.setImage(#imageLiteral(resourceName: "pause"), for: UIControlState())
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = UIColor.init(white: 0.3, alpha: 0.5)
        btn.tintColor = .white
        btn.accessibilityLabel = "Pause"
        return btn
    }()
    
    lazy var closeButton: UIButton = {
        var btn = UIButton(type: .system)
        btn.addSqueeze()
        btn.setImage(#imageLiteral(resourceName: "left-small"), for: UIControlState())
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.tintColor = .white
        btn.accessibilityLabel = "Close"
        return btn
    }()
    
    let backgroundImageView : UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let totalLengthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.getDefautlFont(.meduium, size: 14)
        label.textAlignment = .right
        return label
    }()
    
    let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.getDefautlFont(.meduium, size: 14)
        return label
    }()
    
    var timer : Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        
        self.isAccessibilityElement = false
        self.accessibilityElements = [closeButton, pausePlayButton, currentTimeLabel, totalLengthLabel]
        
        NotificationCenter.default.addObserver(self, selector: #selector(voiceOverNotification(notification:)), name: NSNotification.Name(rawValue: UIAccessibilityVoiceOverStatusChanged), object: nil)
    }
    
    func setupView() {
        self.addSubview(backgroundImageView)
        self.addSubview(closeButton)
        self.addSubview(pausePlayButton)
        self.addSubview(totalLengthLabel)
        self.addSubview(currentTimeLabel)
        
        backgroundImageView.anchorToTop(self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor)
        
        closeButton.anchor(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        
        pausePlayButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        pausePlayButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        pausePlayButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        pausePlayButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        pausePlayButton.layer.cornerRadius = 25
        
        
        totalLengthLabel.anchor(nil, left: nil, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 2, rightConstant: 15, widthConstant: 50, heightConstant: 24)
        
        
        currentTimeLabel.anchor(nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: nil, topConstant: 0, leftConstant: 15, bottomConstant: 2, rightConstant: 0, widthConstant: 50, heightConstant: 24)
        
        setTouchAction(self, action: #selector(handleControlTouch))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTouchAction(_ target: Any, action: Selector) {
        self.addGestureRecognizer(UITapGestureRecognizer(target: target, action: action))
    }
    
    func setCloseAction(_ target: Any, action: Selector) {
        closeButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    func setPlayPauseAction(_ target: Any, action: Selector) {
        pausePlayButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    func showControls(_ show : Bool, delay : TimeInterval = 0.3) {
        controlsShowing = show
        if show || UIAccessibilityIsVoiceOverRunning()  {
            UIView.animate(withDuration: 0.3, delay: delay, options: .curveEaseOut, animations: {
                self.pausePlayButton.alpha = 1
            })
        } else {
            UIView.animate(withDuration: 0.3, delay: delay, options: .curveEaseOut, animations: {
                self.pausePlayButton.alpha = 0
            })
        }
        
    }
    
    @objc func handleControlTouch(){
        if !isPlaying {
            return
        }
        if controlsShowing {
            showControls(false, delay: 0.0)
        } else {
            showControls(true, delay: 0.0)
            timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(automaticHide), userInfo: nil, repeats: false)
        }
    }
    
    @objc func automaticHide() {
        if controlsShowing && isPlaying {
            showControls(false)
        }
        timer?.invalidate()
        timer = nil
    }
    
    @objc func voiceOverNotification(notification: Notification) {
        showControls(UIAccessibilityIsVoiceOverRunning())
    }
}

class MediaSlider : UISlider {
    
    private var thumbImageView : UIImageView?
    
    func expand() {
        self.thumbImageView = self.subviews.last as? UIImageView
        UIView.animate(withDuration: 0.2) {
            self.thumbImageView?.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
        }
    }
    
    func compress() {
        UIView.animate(withDuration: 0.1, animations: {
            self.thumbImageView?.transform = .identity
        })
    }
    
    private var maxValueLabel : String!
    
    override var maximumValue: Float {
        didSet{
            maxValueLabel = Utility.timeAccessibilityString(time: TimeInterval(self.maximumValue))
            setAccessibilityLabel()
        }
    }
    
    override func setValue(_ value: Float, animated: Bool) {
        super.setValue(value, animated: animated)
        setAccessibilityLabel()
    }
    
    override func accessibilityDecrement() {
        super.accessibilityDecrement()
        setAccessibilityLabel()
    }
    override func accessibilityIncrement() {
        super.accessibilityIncrement()
        setAccessibilityLabel()
    }
    
    func setAccessibilityLabel(){
        self.accessibilityValue = "Track Position " + Utility.timeAccessibilityString(time: TimeInterval(self.value)) + " of " + maxValueLabel
    }
}

