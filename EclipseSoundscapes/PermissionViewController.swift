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
        btn.addTarget(self, action: #selector(hide), for: .touchUpInside)
        btn.accessibilityLabel = "Back"
        return btn
    }()
    
    var backgroundView : UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.alpha = 0
        return view
    }()
    
    
    
    /// Show the PermissionView with the given permissions
    ///
    /// - Parameters:
    ///   - permissions: Permissions to show
    ///   - completion: Optional completion after the permission view dismisses
    /// - Returns: PermissionViewController to manage the view
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        permissionView.transform = CGAffineTransform.init(scaleX: CGFloat.leastNonzeroMagnitude
            , y: CGFloat.leastNonzeroMagnitude)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        show()
    }
    
    // Setup and layout view's subviews
    func setupViews() {
        permissionView.delegate = self
        self.view.addSubviews(backgroundView, permissionView)
        
        backgroundView.anchorToTop(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        permissionView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 30, leftConstant: 10, bottomConstant: 30, rightConstant: 10, widthConstant: 0, heightConstant: 0)
        
        permissionView.layer.cornerRadius = 20
        self.permissionView.layer.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
        
        permissionView.addSubviews(backBtn)
        backBtn.centerYAnchor.constraint(equalTo: permissionView.titleLabel.centerYAnchor).isActive = true
        backBtn.leftAnchor.constraint(equalTo: permissionView.leftAnchor, constant: 10).isActive = true
        
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(self.handlePan(_:)))
        panGesture.maximumNumberOfTouches = 1
        self.permissionView.addGestureRecognizer(panGesture)
    }
    
    //MARK: - Drag and Pan animations for dismissing View
    
    /// Controller's Center
    var centerPoint: CGPoint {
        return view.center
    }
    
    /// Handle drag and pan animations
    ///
    /// - Parameter recognizer: UIPanGestureRecognizer
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
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
                
                let center = movingCenter.y + contentView.frame.height/4
                
                let bottom = view.frame.height
                if center > bottom {
                    willDismiss = true
                }
                else {
                    willDismiss = false
                }
                
                if movingCenter.y > self.centerPoint.y {
                    let distanceMoved = movingCenter.y - self.centerPoint.y
                    let percent = (bottom-distanceMoved)/bottom
                    contentView.alpha = percent
                    self.backgroundView.alpha = percent
                } else {
                    contentView.alpha = 1.0
                    self.backgroundView.alpha = 1.0
                }
                
                
                recognizer.setTranslation(CGPoint.zero, in : view)
                
                break
            case .ended:
                if willDismiss {
                    self.gravityHide()
                    return
                }
                else {
                    returnCenter()
                }
                break
            default:
                break
            }
        }
    }
    
    /// Animate the showing of the permissionView
    func show() {
        UIView.animate(withDuration: 0.5) {
            self.backgroundView.alpha = 1.0
            
        }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveLinear, animations: {
            self.permissionView.transform = .identity
        }, completion: nil)
    }
    
    
    /// Animate the close the permissionView
    @objc func hide() {
        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundView.alpha = 0.0
            self.permissionView.alpha = 0.0
            self.permissionView.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
        }, completion: { (_) in
            self.close()
        })
    }
    
    /// Animate the close the permissionView
    func gravityHide() {
        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundView.alpha = 0.0
            self.permissionView.transform = CGAffineTransform.init(translationX: 0, y: 1000)
        }, completion: { (_) in
            self.close()
        })
    }
    
    
    /// Close the controller and call completion
    @objc fileprivate func close() {
        self.dismiss(animated: true) {
            self.completion()
        }
    }
    
    func returnCenter() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveLinear, animations: {
            self.permissionView.center = self.centerPoint
            self.permissionView.transform = CGAffineTransform.identity
            self.permissionView.alpha = 1.0
            self.backgroundView.alpha = 1.0
        }, completion: nil)
    }
}

extension PermissionViewController: PermissionViewDelegate {
    func didFinish() {
        Utility.delay(0.3) { [weak self] in
            self?.close()
        }
    }
}
