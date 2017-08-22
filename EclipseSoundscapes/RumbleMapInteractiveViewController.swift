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
import SwiftSpinner

class RumbleMapInteractiveViewController: UIViewController {
    
    var event : Event? {
        didSet {
            self.rumbleMap.event = event
        }
    }
    
    var rumbleMap :  RumbleMap!
    
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
    
    var closeCompletion : (()->Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rumbleMap = RumbleMap()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rumbleMap.setSession(active: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        rumbleMap.setSession(active: false)
    }
    
    func setupView() {
        rumbleMap.target =  { [weak self] in
            return self?.fix()
        }
        
        view.addSubview(rumbleMap)
        view.addSubview(closeBtn)
        view.addSubview(instructionBtn)
        view.addSubview(lineSeparatorView1)
        view.addSubview(lineSeparatorView2)
        
        rumbleMap.anchorToTop(view.topAnchor, left: view.leftAnchor, bottom: closeBtn.topAnchor, right: view.rightAnchor)
        
        closeBtn.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.centerXAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0.5, widthConstant: 0, heightConstant: 50)
        instructionBtn.anchor(nil, left: view.centerXAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0.5, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50)
        
        lineSeparatorView1.anchor(nil, left: view.leftAnchor, bottom: closeBtn.topAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 1)
        lineSeparatorView2.anchor(closeBtn.topAnchor, left: closeBtn.rightAnchor, bottom: view.bottomAnchor, right: instructionBtn.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    
    func fix() {
        rumbleMap.isActive = false
        
        if closeBtn.accessibilityElementIsFocused() {
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, closeBtn)
        } else {
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, instructionBtn)
        }
        
    }
        
    func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func openInstructions() {
        self.present(IntructionsViewController(), animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
}
