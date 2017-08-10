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
//            self.accessibilityLabel = "Double Tap to \(isPlaying ? "Pause" : "Play")"
            pausePlayButton.accessibilityLabel = isPlaying ? "Pause" : "Play"
        }
    }
    
    
    lazy var pausePlayButton: SqueezeButton = {
        let button = SqueezeButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "pause"), for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.init(white: 0.3, alpha: 0.5)
        button.tintColor = .white
        button.accessibilityLabel = "Pause"
        return button
    }()
    
    lazy var closeButton: SqueezeButton = {
        let button = SqueezeButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "left-small"), for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.accessibilityLabel = "Close"
        return button
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
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupGradientLayer()
    }
    
    func setupView() {
        self.addSubview(backgroundImageView)
        self.addSubview(closeButton)
        self.addSubview(pausePlayButton)
        self.addSubview(totalLengthLabel)
        self.addSubview(currentTimeLabel)
        
        backgroundImageView.anchorToTop(self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor)
        
        closeButton.anchorWithConstantsToTop(self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 0)
        
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
                self.gradientLayer.opacity = 1
            })
        } else {
            UIView.animate(withDuration: 0.3, delay: delay, options: .curveEaseOut, animations: {
                self.pausePlayButton.alpha = 0
                self.gradientLayer.opacity = 0
            })
        }
        
    }
    
    func handleControlTouch(){
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
    
    func automaticHide() {
        if controlsShowing && isPlaying {
            showControls(false)
        }
        timer?.invalidate()
        timer = nil
    }
    
    var gradientLayer : CAGradientLayer!
    fileprivate func setupGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.frame
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.7, 1.2]
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}

class MediaSlider : UISlider {
    
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
        self.accessibilityValue = Utility.timeAccessibilityString(time: TimeInterval(self.value)) + " of " + maxValueLabel
    }
}

