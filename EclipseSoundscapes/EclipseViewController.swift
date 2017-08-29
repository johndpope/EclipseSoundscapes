//
//  EclipseViewController.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 7/25/17.
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

import Eureka
import CoreLocation
import SwiftSpinner
import BRYXBanner
import Material

class EclipseViewController : FormViewController {
    
    @IBOutlet weak var errorBtn: UIButton!
    var banner : Banner?
    
    var locator = Location()
    
    var isSpinnerShowing = false
    
    var foundLocationOnce = false
    
    var LocationKey : String?
    
    var noEclipseView : NoEclipseView?
    
    deinit {
        LocationManager.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeForm()
        configureContent()
        LocationManager.addObserver(self)
        if Location.isGranted {
            getlocation(animated: !foundLocationOnce)
        }
        
        NotificationHelper.addObserver(self, reminders: .contact1, selector: #selector(hideCountdown))
    }
    
    private func initializeForm() {
        
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.contentInset = UIEdgeInsetsMake(25, 0, 44, 0)
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(20, 0, 0, 0)
        
        tableView.isHidden = true
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.backgroundColor = .clear
        
        LabelRow.defaultCellUpdate = { cell, row in
            cell.backgroundColor = .clear
            
            cell.textLabel?.font = UIFont.getDefautlFont(.meduium, size: 18)
            cell.textLabel?.textColor = .white
            
            cell.detailTextLabel?.font = UIFont.getDefautlFont(.meduium, size: 16)
            cell.detailTextLabel?.textColor = .white
            
            cell.textLabel?.adjustsFontSizeToFitWidth = true
             cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
            
            cell.height = {30}
        }
        form
            
            +++ Section() {
                var header = HeaderFooterView<LogoView>(.nibFile(name: "SectionHeader", bundle: nil))
                header.onSetupView = { (view, section) -> () in
                    view.imageView.alpha = 0;
                    UIView.animate(withDuration: 2.0, animations: { [weak view] in
                        view?.imageView.alpha = 1
                    })
                    view.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1)
                    UIView.animate(withDuration: 1.0, animations: { [weak view] in
                        view?.layer.transform = CATransform3DIdentity
                    })
                }
                switch UIDevice.current.userInterfaceIdiom {
                case .pad:
                    header.height = {self.view.frame.width * 9 / 16}
                default:
                    break
                }
                
                $0.header = header
            }

            +++ CountDownRow("Countdown"){
                    $0.hidden = Condition.init(booleanLiteral: UserDefaults.standard.bool(forKey: "Contact1Done"))
                }
                .cellSetup({ (cell, row) in
                    cell.backgroundColor = .clear
                }).cellUpdate({ (cell, row) in
                    row.evaluateHidden()
                })
            <<< LabelRow ("Type") { row in
                row.title = "Eclipse Type: "
            }
            <<< LabelRow ("Date") { row in
                row.title = "Date: "
            }
            
            <<< LabelRow ("Latitude") { row in
                row.title = "Your Latitude: "
            }
            <<< LabelRow ("Longitude") { row in
                row.title = "Your Longitude: "
            }
            <<< LabelRow ("Coverage") { row in
                row.title = "% Eclipse: "
        }
        
        
        
        let section = form.allSections[1]
        section.header = HeaderFooterView<UIView>(HeaderFooterProvider.class)
        section.header?.height = {CGFloat.leastNormalMagnitude}
    }
    
    func configureContent() {
        
        let background = UIView.rombusPattern()
        background.frame = view.bounds
        background.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(background, at: 0)
        
        errorBtn.backgroundColor = .clear
        errorBtn.addTarget(self, action: #selector(didTapErrorBtn), for: .touchUpInside)
        errorBtn.titleLabel?.font = UIFont.getDefautlFont(.bold, size: 25)
        errorBtn.setTitleColor(.white, for: .normal)
        errorBtn.titleLabel?.numberOfLines = 0
        errorBtn.titleLabel?.textAlignment = .center
        errorBtn.setTitle(Location.string.general, for: .normal)
        
    }
    
    func hideCountdown() {
        if let row = form.rowBy(tag: "Countdown") as? CountDownRow {
            row.hidden = true
            row.evaluateHidden()
        }
        NotificationHelper.removeObserver(self, reminders: .contact1)
    }
    
    func didTapErrorBtn() {
        getlocation(animated: true)
    }
    
    func getlocation(animated : Bool) {
        banner?.dismiss()
        
        if Location.isGranted {
            if animated {
                showSpinner()
            }
            LocationManager.getLocation()
        } else {
            if !Location.checkPermission() {
                LocationManager.permission(on: self)
            } else {
                banner = Banner(title: "Location Settings is Turned off", subtitle: "Go to More > Settings > Enable Location or Tap to go.", image: #imageLiteral(resourceName: "EclipseSoundscapes-Eclipse"), backgroundColor: Color.eclipseOrange, didTapBlock: {
                    self.present(UINavigationController(rootViewController: SettingsViewController()), animated: true, completion: nil)
                })
                banner?.show(duration: 5.0)
            }
        }
    }
    
    func showSpinner() {
        isSpinnerShowing = true
        SwiftSpinner.setTitleFont(UIFont.getDefautlFont(.bold, size: 22))
        SwiftSpinner.useContainerView(self.view)
        let spinner = SwiftSpinner.show("Finding Your location", animated: true)
        spinner.addTapHandler({
            self.showError()
        }, subtitle: "Tap To Stop")
        
        spinner.accessibilityElements = [spinner.titleLabel]
        spinner.titleLabel.accessibilityLabel = title
        if let hint = spinner.subtitleLabel?.text {
            spinner.titleLabel.accessibilityHint = "Double \(hint)"
        }
        errorBtn.isAccessibilityElement = false
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, spinner)
    }
    
    func hideSpinner() {
        SwiftSpinner.hide()
        errorBtn.isAccessibilityElement = true
    }
    
    func showError(_ completion: (()->Void)? = nil ) {
        if self.isSpinnerShowing {
            self.hideSpinner()
        }
        self.errorBtn.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.tableView.alpha = 0.0
            self.errorBtn.alpha = 1.0
        }, completion: { (_) in
            self.tableView.isHidden = true
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.errorBtn)
            completion?()
        })
    }
    
    func hideError(_ completion: (()->Void)? = nil) {
        tableView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.tableView.alpha = 1.0
            self.errorBtn.alpha = 0.0
        }, completion: { (_) in
            self.errorBtn.isHidden = true
            completion?()
        })
    }
    
    func setCountdown(_ date: Date?, atUserLocation: Bool = true) {
        guard let eclipseDate = date else {
            print("Not Valid Format")
            return
        }
        
        if let countdownRow = form.rowBy(tag: "Countdown") as? CountDownRow {
            countdownRow.set(date: eclipseDate)
            if atUserLocation {
                countdownRow.cell.countdownView.accessibilityLabel = "Countdown Until Eclipse from your location"
            } else {
                countdownRow.cell.countdownView.accessibilityLabel = "Countdown Until Eclipse from Closest location"
            }
            
        }
        
        
    }
    
    func addContent(timeGenerator : EclipseTimeGenerator, atUserLocation : Bool = true) {
        
        var eclipseInfo : [EclipseEvent]!
        
        switch timeGenerator.eclipseType {
        case .none:
            toggleNoEclipse(show: true)
            return
        case .partial:
            eclipseInfo = [timeGenerator.contact1, timeGenerator.contactMid, timeGenerator.contact4]
            
            if let typeRow = form.rowBy(tag: "Type") as? LabelRow{
                typeRow.value = "Partial Solar Eclipse"
                typeRow.cell.detailTextLabel?.text = "Partial Solar Eclipse"
            }
            
            break
        case .full :
            eclipseInfo = [timeGenerator.contact1, timeGenerator.contact2, timeGenerator.contactMid, timeGenerator.contact3, timeGenerator.contact4]
            
            if let typeRow = form.rowBy(tag: "Type") as? LabelRow {
                typeRow.value = "Total Solar Eclipse"
                typeRow.cell.detailTextLabel?.text = "Total Solar Eclipse"
                
                
                if let durationRow = form.rowBy(tag: "Duration") as? LabelRow{
                    durationRow.value = timeGenerator.duration!
                    durationRow.cell.detailTextLabel?.text = timeGenerator.duration!
                } else {
                    if let section = typeRow.section {
                        section
                            <<< LabelRow ("Duration") { row in
                                row.title = "Duration of Totality: "
                                row.value = timeGenerator.duration!
                            }
                    }
                    
                }
            }
            break
        }
        
    
        
        updatelocation(lat: timeGenerator.latString, long: timeGenerator.lonString, atUserLocation: atUserLocation)
        setCountdown(timeGenerator.contact1.eventDate(), atUserLocation: atUserLocation)
        
        if let dateRow = form.rowBy(tag: "Date") as? LabelRow{
            dateRow.value = timeGenerator.contact1.date
            dateRow.cell.detailTextLabel?.text = timeGenerator.contact1.date
        }
        
        if let coverageRow = form.rowBy(tag: "Coverage") as? LabelRow {
            coverageRow.value = timeGenerator.coverage
            coverageRow.cell.detailTextLabel?.text = timeGenerator.coverage
        }
        
        
        if let infoSection = form.sectionBy(tag: "EventTimes") {
            form.remove(at: infoSection.index!)
        }
        
        let infoSection = Section(){section in
            section.tag = "EventTimes"
            section.header = {
                var header = HeaderFooterView<UIView>(HeaderFooterProvider.class)
                header.height = {CGFloat.leastNormalMagnitude}
                return header
            }()
        }
        
        let heading = InfoRow().cellSetup({ (cell, row) in
            cell.backgroundColor = UIColor.init(r: 214, g: 93, b: 18)
            cell.height = {50}
            cell.eventLabel.textColor = .black
            cell.localTimeLabel.textColor = .black
            cell.timeLabel.textColor = .black
            
            cell.eventLabel.font = UIFont.getDefautlFont(.meduium, size: 18)
            cell.localTimeLabel.font = UIFont.getDefautlFont(.meduium, size: 18)
            cell.timeLabel.font = UIFont.getDefautlFont(.meduium, size: 18)
            cell.toggleAccessibility(false, atUserLocation: atUserLocation)
        })
        
        
        form
            +++ infoSection
            <<< heading
        
        for event in eclipseInfo {
            infoSection
                <<< InfoRow() { row in
                    row.value = event
                    }.cellSetup({ (cell, row) in
                        cell.backgroundColor = .clear
                        cell.height = {50}
                        
                    }).cellUpdate({ (cell, row) in
                        cell.set(row.value, atUserLocation: atUserLocation)
                    })
            
        }
    }
    
    func updatelocation(lat : String, long: String, atUserLocation : Bool = true){
        guard let latRow = form.rowBy(tag: "Latitude") as? LabelRow, let longRow = form.rowBy(tag: "Longitude") as? LabelRow else {
            return
        }
        
        if atUserLocation {
            latRow.title = "Your Latitude: "
            longRow.title = "Your Longitude: "
            
            latRow.cell.textLabel?.text = "Your Latitude: "
            longRow.cell.textLabel?.text = "Your Longitude: "
        } else {
            latRow.title = "Location's Latitude: "
            longRow.title = "Location's Longitude: "
            
            latRow.cell.textLabel?.text = "Location's Latitude: "
            longRow.cell.textLabel?.text = "Location's Longitude: "
        }
        
        latRow.value = lat
        longRow.value = long
        
        latRow.cell.detailTextLabel?.text = lat
        longRow.cell.detailTextLabel?.text = long
    }
    
    func getClosesLocation() {
        LocationManager.getClosestLocation()
        toggleNoEclipse(show: false)
    }
    
    var currentAccessibleElements : [Any]?
    
    func toggleNoEclipse(show: Bool){
        
        if show {
            
            if noEclipseView != nil {
                return
            }
            self.tableView.isAccessibilityElement = false
            noEclipseView = NoEclipseView()
            view.addSubview(noEclipseView!)
            noEclipseView?.anchorToTop(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
            noEclipseView?.setAction(self, action: #selector(getClosesLocation))
            
            view.accessibilityElements = [noEclipseView!]
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.noEclipseView)
        } else {
            self.tableView.isAccessibilityElement = true
            view.accessibilityElements = [tableView]
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.tableView)
            
            UIView.animate(withDuration: 0.3, animations: { 
                self.noEclipseView?.alpha = 0
            }, completion: { (_) in
                self.noEclipseView?.removeFromSuperview()
                self.noEclipseView = nil
            })
        }
    }
    
    override func insertAnimation(forRows rows: [BaseRow]) -> UITableViewRowAnimation {
        return .fade
    }
    
    override func insertAnimation(forSections sections: [Section]) -> UITableViewRowAnimation {
        return .fade
    }
    
    override func deleteAnimation(forRows rows: [BaseRow]) -> UITableViewRowAnimation {
        return .fade
    }
    
    override func deleteAnimation(forSections sections: [Section]) -> UITableViewRowAnimation {
        return .fade
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension EclipseViewController : LocationDelegate {
    /// Ask the User if they would like to be put on the path of Totality at the closest point from them
    func notOnToaltiyPath() {
        toggleNoEclipse(show: true)
    }

    
    func locator(didUpdateBestLocation location: CLLocation) {
        let timeGenerator = EclipseTimeGenerator(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        addContent(timeGenerator: timeGenerator, atUserLocation: LocationManager.isUsersLocation)
        hideError {
            if self.isSpinnerShowing {
                self.hideSpinner()
            }
            if !self.foundLocationOnce {
                UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.tableView)
                self.foundLocationOnce = true
            }
        }
        
    }
    
    func locator(didFailWithError error: Error) {
        let code = CLError(_nsError: error as NSError)
        switch code {
        case CLError.locationUnknown:
            let spinner = SwiftSpinner.sharedInstance
            spinner.title = Location.string.locationUnknown
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
        showError()
        
    }
    
    func notGranted() {
        showError()
        
        if !Location.isGranted {
            banner = Banner(title: "Location Settings is Turned off", subtitle: "Go to More > Settings > Enable Location or Tap to go.") {
                self.present(UINavigationController(rootViewController: SettingsViewController()), animated: true, completion: nil)
            }
            banner?.show(duration: 5.0)
        } else {
            LocationManager.permission(on: self)
        }
    }
    
    func didGrant() {
        showSpinner()
    }
}
