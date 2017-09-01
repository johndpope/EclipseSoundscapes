//
//  PermissionViewController.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 8/26/17.
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

class PermissionViewController : UIViewController {
    private var permissionView : PermissionView!
    private var completion : (()->Void)!
    
    var didTouchButton = false
    var willDismiss = false
    
    lazy var backBtn : UIButton = {
        var btn = UIButton(type: .system)
        btn.addSqueeze()
        btn.setImage(#imageLiteral(resourceName: "Left_Arrow").withRenderingMode(.alwaysTemplate), for: .normal)
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(close), for: .touchUpInside)
        btn.accessibilityLabel = "Back"
        return btn
    }()
    
    
    
    class func show(with permissions: [PermissionType], completion: @escaping ()->Void) -> PermissionViewController{
        let permissionVc = PermissionViewController()
        permissionVc.modalPresentationStyle = .overCurrentContext
        permissionVc.permissionView = PermissionView(for: permissions)
        permissionVc.completion = completion
        return permissionVc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        view.backgroundColor = .clear
        view.isOpaque = false
        
        
    }
    
    // Setup and layout view's subviews
    func setupViews() {
        permissionView.delegate = self
        self.view.addSubview(permissionView)
        
        permissionView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 30, leftConstant: 10, bottomConstant: 30, rightConstant: 10, widthConstant: 0, heightConstant: 0)
        
        permissionView.cornerRadius = 20
        self.permissionView.layer.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
        
        
        
        permissionView.addSubview(backBtn)
        backBtn.anchorWithConstantsToTop(permissionView.topAnchor, left: permissionView.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 0)
        
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(self.handlePan(_:)))
        panGesture.maximumNumberOfTouches = 1
        self.permissionView.addGestureRecognizer(panGesture)
    }
    
    
    func didFinish() {
        Utility.delay(0.5) { [weak self] in
            self?.close()
        }
    }
    
    @objc private func close() {
        self.dismiss(animated: true) {
            self.completion()
        }
    }
    
    //MARK: - animator
    
    var centerPoint: CGPoint {
        return view.center
    }
    
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        if !didTouchButton {
            
            let contentView = recognizer.view!
            switch recognizer.state {
            case .began:
                UIView.animate(withDuration: 0.2, animations: {
                    self.permissionView.transform = CGAffineTransform.init(scaleX: 0.90, y: 0.90)
                })
                break
            case .changed:
                let panOffset = recognizer.translation(in: view)
                
                let movingCenter = CGPoint(x: contentView.center.x + panOffset.x, y: contentView.center.y + panOffset.y)
                recognizer.view!.center = movingCenter
                
                let center = movingCenter.y + contentView.height/4
                
                let bottom = view.height
                if center > bottom {
                    willDismiss = true
                }
                else {
                    willDismiss = false
                }
                
                if movingCenter.y > self.centerPoint.y {
                    let distanceMoved = movingCenter.y - self.centerPoint.y
                    let percent = (bottom-distanceMoved)/bottom
                    print("percent: \(percent)")
                    contentView.alpha = percent
                } else {
                    contentView.alpha = 1
                }
                
                
                recognizer.setTranslation(CGPoint.zero, in : view)
                
                break
            case .ended:
                if willDismiss {
                    self.hide()
                    return
                }
                else {
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveLinear, animations: {
                        contentView.center = self.centerPoint
                        contentView.transform = CGAffineTransform.identity
                        contentView.alpha = 1.0
                    }, completion: nil)
                }
                break
            default:
                break
            }
        }
    }
    
    
    func hide() {
        permissionView.animate([.translate(x: 0, y: 1000, z: 0),.scale(0.9), .fadeOut]) {
            self.close()
        }
        
    }
}

extension PermissionViewController: PermissionViewDelegate {
    
}
