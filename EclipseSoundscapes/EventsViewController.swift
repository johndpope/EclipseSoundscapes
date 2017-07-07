//
//  EventsViewController.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 6/21/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

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
        if self.isSpinnerShowing {
            self.hideSpinner()
        }
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
        } else {
            showError()
        }
    }
    
    func didAllowPermission(permission: SPRequestPermissionType) {
        
    }
    
    func didDeniedPermission(permission: SPRequestPermissionType) {
        
    }
    
    func didSelectedPermission(permission: SPRequestPermissionType) {
        
    }
}
