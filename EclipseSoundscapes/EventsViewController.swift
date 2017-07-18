//
//  EventsViewController.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 6/21/17.
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
import CoreLocation
import SwiftSpinner
import BRYXBanner


class EventsViewController: UIViewController {
    
    @IBOutlet weak var errorBtn: UIButton!
    
    @IBOutlet weak var countDownView: CountdownView!
    var infoView: InfoView!
    
    var locator = Location()
    
    var foundLocationOnce = false
    var isSpinnerShowing = false
    
    var banner : Banner?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view
        locator.delegate = self
        
        configureContent()
        setText()
        
        (view as! UIScrollView).delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let contentHight = infoView.height+countDownView.frame.height + 15
        let screenheight = view.frame.height
        
        if contentHight > screenheight {
            (view as! UIScrollView).contentSize = CGSize(width: (view as! UIScrollView).contentSize.width, height: contentHight)
        } else {
            (view as! UIScrollView).contentSize = CGSize(width: (view as! UIScrollView).contentSize.width, height: screenheight)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        banner?.dismiss()
    }
    
    func configureContent() {
        
        errorBtn.addTarget(self, action: #selector(didTapErrorBtn), for: .touchUpInside)
        errorBtn.titleLabel?.numberOfLines = 0
        errorBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        errorBtn.titleLabel?.textAlignment = .center
        errorBtn.setTitle(Location.string.general, for: .normal)
        
        
        countDownView.translatesAutoresizingMaskIntoConstraints = false
        
        infoView = InfoView()
        infoView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(infoView)
        countDownView.bottomAnchor.constraint(equalTo: infoView.topAnchor).isActive = true
        
        infoView.topAnchor.constraint(equalTo: countDownView.bottomAnchor).isActive = true
        infoView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        infoView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        infoView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        countDownView.alpha = 0
        infoView.alpha = 0
        showError()
    }
    
    func setText() {
        
        errorBtn.titleLabel?.font = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(fontName: .bold, textStyle: .headline, scale: 1.5), size: 0)
    }
    
    func setCountdown(_ dateString: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss.S"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        guard let eclipseDate = dateFormatter.date(from: dateString) else {
            print("Not Valid Format")
            return
        }
        countDownView?.startCountdown(eclipseDate, onCompleted: {
            
            self.countDownView?.isHidden = true
        })
        
    }
    
    func didTapErrorBtn() {
        getlocation(animated: true)
    }
    
    func getlocation(animated : Bool) {
        if Location.checkPermission() {
            if animated {
                showSpinner()
            }
            locator.getLocation()
        } else {
            Location.permission(on: self)
        }
    }
    
    func showSpinner() {
        isSpinnerShowing = true
        SwiftSpinner.setTitleFont(UIFont.getDefautlFont(.bold, size: 22))
        let spinner = SwiftSpinner.show("Finding Your location", animated: true)
        spinner.addTapHandler({
            self.hideSpinner()
            self.showError({ 
                self.locator.stopLocating()
            })
        }, subtitle: "Tap To Stop")
        
        spinner.accessibilityElements = [spinner.titleLabel]
        spinner.titleLabel.accessibilityLabel = title
        if let hint = spinner.subtitleLabel?.text {
            spinner.titleLabel.accessibilityHint = "Double \(hint)"
        }
        
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, spinner.titleLabel)
        view.accessibilityElementsHidden = true
        self.tabBarController?.tabBar.accessibilityElementsHidden = true
    }
    
    func hideSpinner() {
        SwiftSpinner.hide()
        view.accessibilityElementsHidden = false
        self.tabBarController?.tabBar.accessibilityElementsHidden = false
    }
    
    func showError(_ completion: (()->Void)? = nil ) {
        if self.isSpinnerShowing {
            self.hideSpinner()
        }
        self.errorBtn.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.countDownView.alpha = 0.0
            self.infoView.alpha = 0.0
            self.errorBtn.alpha = 1.0
        }, completion: { (_) in
            self.countDownView.isHidden = true
            self.infoView.isHidden = true
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.errorBtn)
            completion?()
        })
    }
    
    func hideError(_ completion: (()->Void)? = nil) {
        self.countDownView.isHidden = false
        self.infoView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.countDownView.alpha = 1.0
            self.infoView.alpha = 1.0
            self.errorBtn.alpha = 0.0
        }, completion: { (_) in
            self.errorBtn.isHidden = true
            completion?()
        })
    }
    
    fileprivate var isHiddenStatusBar: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.3) { () -> Void in
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var prefersStatusBarHidden: Bool {
        return isHiddenStatusBar
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
}
extension EventsViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        isHiddenStatusBar = scrollView.contentOffset.y > 0
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isHiddenStatusBar = scrollView.contentOffset.y > 0
    }
}

extension EventsViewController : LocationDelegate {
    
    func locator(didUpdateBestLocation location: CLLocation) {
        let timeGenerator = EclipseTimeGenerator(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        setCountdown("\(timeGenerator.contact1.date) \(timeGenerator.contact1.time)")
        infoView.timeGenerator = timeGenerator
        foundLocationOnce = true
        hideError { 
            if self.isSpinnerShowing {
                self.hideSpinner()
            }
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.countDownView)
        }
        
    }
    
    func locator(didFailWithError error: Error) {
        let code = CLError(_nsError: error as NSError)
        switch code {
        case CLError.locationUnknown:
            let spinner = SwiftSpinner.sharedInstance
            spinner.subtitleLabel?.text? = Location.string.locationUnknown + "Tap to Stop"
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, spinner.subtitleLabel)
            return
        case CLError.denied:
            errorBtn.setTitle(Location.string.denied, for: .normal)
            break
        case CLError.network:
            errorBtn.setTitle(Location.string.network, for: .normal)
            break
        default:
            errorBtn.setTitle(Location.string.unkown, for: .normal)
            break
        }
        showError {
            self.infoView.clear()
            self.countDownView.clear()
            self.locator.stopLocating()
        }
        
    }
    
    func notGranted() {
        banner = Banner(title: "Location Settings is Turned off", subtitle: "Go to More > Settings > Enable Location or Tap to go.") {
            self.present(UINavigationController(rootViewController: SettingsViewController()), animated: true, completion: nil)
        }
        banner?.show(duration: 5.0)
        showError {
            self.infoView.clear()
            self.countDownView.clear()
            self.locator.stopLocating()
        }
    }
}

extension EventsViewController : SPRequestPermissionEventsDelegate {
    func didHide() {
        if Location.checkPermission() {
            errorBtn.setTitle(Location.string.general, for: .normal)
            getlocation(animated: true)
            Location.isGranted = true
        } else {
            showError()
            Location.isGranted = false
        }
    }
    
    func didAllowPermission(permission: SPRequestPermissionType) {
        
    }
    
    func didDeniedPermission(permission: SPRequestPermissionType) {
        
    }
    
    func didSelectedPermission(permission: SPRequestPermissionType) {
        
    }
}
