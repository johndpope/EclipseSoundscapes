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

class EclipseViewController : FormViewController {
    
    @IBOutlet weak var errorBtn: UIButton!
    var banner : Banner?
    
    var locator = Location()
    
    var isSpinnerShowing = false
    
    var foundLocationOnce = false
    
    var LocationKey : String?
    
    deinit {
        LocationManager.removeObserver(key: LocationKey)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeForm()
        configureContent()
        LocationKey = LocationManager.addObserver(self)
    }
    
    private func initializeForm() {
        
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.contentInset = UIEdgeInsetsMake(25, 0, 44, 0)
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(20, 0, 0, 0)
        
        tableView.isHidden = true
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
//        tableView.backgroundView = UIView.rombusPattern()
        tableView.backgroundColor = .clear
        
        LabelRow.defaultCellUpdate = { cell, row in
            cell.backgroundColor = .clear
            
            cell.textLabel?.font = UIFont.getDefautlFont(.meduium, size: 18)
            cell.textLabel?.textColor = .white
            
            cell.detailTextLabel?.font = UIFont.getDefautlFont(.meduium, size: 16)
            cell.detailTextLabel?.textColor = .white
            
            cell.height = {30}
        }
        form
            +++ CountDownRow("Countdown")
                .cellSetup({ (cell, row) in
                    cell.backgroundColor = .clear
                })
            <<< LabelRow ("Type") { row in
                row.title = "Eclipse Type: "
                row.value = "Partial Solar Eclipse"
            }
            <<< LabelRow ("Date") { row in
                row.title = "Date: "
                row.value = "8-21-2017"
            }
            
            <<< LabelRow ("Latitude") { row in
                row.title = "My Latitude: "
                row.value = "42.09"
            }
            <<< LabelRow ("Longitude") { row in
                row.title = "My Longitude: "
                row.value = "83.08"
            }
            <<< LabelRow ("Coverage") { row in
                row.title = "% Eclipse: "
        }
        
        
        
        let section = form.allSections[0]
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
                banner = Banner(title: "Location Settings is Turned off", subtitle: "Go to More > Settings > Enable Location or Tap to go.") {
                    self.present(UINavigationController(rootViewController: SettingsViewController()), animated: true, completion: nil)
                }
                banner?.show(duration: 5.0)
            }
        }
    }
    
    func showSpinner() {
        isSpinnerShowing = true
        SwiftSpinner.setTitleFont(UIFont.getDefautlFont(.bold, size: 22))
        let spinner = SwiftSpinner.show("Finding Your location", animated: true)
        spinner.addTapHandler({
            self.hideSpinner()
            self.showError({
                LocationManager.stopLocating()
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
    
    func setCountdown(_ dateString: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss.S"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        guard let eclipseDate = dateFormatter.date(from: dateString) else {
            print("Not Valid Format")
            return
        }
        
        if let countdownRow = form.rowBy(tag: "Countdown") as? CountDownRow {
            countdownRow.set(date: eclipseDate)
        }
        
        
    }
    
    func addContent(timeGenerator : EclipseTimeGenerator) {
        
        var eclipseInfo : [EclipseEvent]!
        
        switch timeGenerator.eclipseType {
        case .none:
            //            eclipseTypeLabel.text = "No Solar Eclipse"
            //            tableView.isHidden = true
            ////            layoutIfNeeded()
            return
        case .partial:
            eclipseInfo = [timeGenerator.contact1, timeGenerator.contactMid, timeGenerator.contact4]
            
            if let typeRow = form.rowBy(tag: "Type") as? LabelRow{
                typeRow.value = "Partial Solar Eclipse"
            }
            
            break
        case .full :
            eclipseInfo = [timeGenerator.contact1, timeGenerator.contact2, timeGenerator.contactMid, timeGenerator.contact3, timeGenerator.contact4]
            
            if let typeRow = form.rowBy(tag: "Type") as? LabelRow {
                typeRow.cell.detailTextLabel?.text = "Total Solar Eclipse"
                
                
                if let durationRow = form.rowBy(tag: "Duration") as? LabelRow{
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
        
        
        if let coverageRow = form.rowBy(tag: "Coverage") as? LabelRow {
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
            cell.toggleAccessibility(false)
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
                    })
            
        }
    }
    
    func updatelocation(lat : String, long: String){
        guard let latRow = form.rowBy(tag: "Latitude") as? LabelRow, let longRow = form.rowBy(tag: "Longitude") as? LabelRow else {
            return
        }
        
        latRow.cell.detailTextLabel?.text = lat
        longRow.cell.detailTextLabel?.text = long
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
    
    func locator(didUpdateBestLocation location: CLLocation) {
        let timeGenerator = EclipseTimeGenerator(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        updatelocation(lat: timeGenerator.latString, long: timeGenerator.lonString)
        setCountdown("\(timeGenerator.contact1.date) \(timeGenerator.contact1.time)")
        addContent(timeGenerator: timeGenerator)
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
            spinner.addTapHandler({
                self.showError()
            }, subtitle: Location.string.locationUnknown + "\nTap to Stop.")
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
            LocationManager.stopLocating()
        }
        
    }
    
    func notGranted() {
        showError {
            LocationManager.stopLocating()
        }
        
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
