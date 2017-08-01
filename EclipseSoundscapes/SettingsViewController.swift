//
//  SettingsViewController.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 7/18/17.
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


class SettingsViewController : FormViewController {
    
    var currentSetting : SPRequestPermissionType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeForm()
        self.navigationItem.title = "Settings"
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "left-small"), style: .plain, target: self, action: #selector(close))
        button.tintColor = .black
        button.accessibilityLabel = "Back"
        self.navigationItem.leftBarButtonItem = button
    }
    
    @objc private func initializeForm() {
        
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.contentInset = UIEdgeInsetsMake((self.navigationController?.navigationBar.frame.height)! + (self.navigationController?.navigationBar.frame.origin.y)! + 20, 0, 0, 0)
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake((self.navigationController?.navigationBar.frame.height)! + (self.navigationController?.navigationBar.frame.origin.y)! + 20, 0, 0, 0)
        
        form
            +++ SwitchRow("Notification") {
                $0.title = "Notifications"
                $0.value = SPRequestPermission.isAllowPermission(.notification)
                }.onChange({ (row) in
                    if let switchOn = row.value {
                        if switchOn {
                            NotificationHelper.appGrated = true
                            if !NotificationHelper.isGranted{
                                self.currentSetting = .notification
                                SPRequestPermission.dialog.interactive.present(on: self, with: [.notification],dataSource: NotificationDataSource(), delegate: self)
                            }
                        } else {
                            NotificationHelper.appGrated = false
                        }
                    }
                    
                })
            <<< SwitchRow("Location") {
                $0.title = "Location"
                $0.value = SPRequestPermission.isAllowPermission(.locationWhenInUse) && Location.isGranted
                }.onChange({ (row) in
                    if let switchOn = row.value {
                        if switchOn {
                            Location.appGrated = true
                            if !Location.isGranted{
                                self.currentSetting = .locationWhenInUse
                                SPRequestPermission.dialog.interactive.present(on: self, with: [.locationWhenInUse],dataSource: LocationDataSource(), delegate: self)
                            }
                        } else {
                            Location.appGrated = false
                        }
                    }
                })
    }
    
    @objc private func close() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SettingsViewController: SPRequestPermissionEventsDelegate {
    
    func didHide() {
        guard let type = currentSetting else {
            return
        }
        switch type {
        case .notification:
            let isAllowed = NotificationHelper.checkPermission()
            NotificationHelper.appGrated = isAllowed
            let row = (form.rowBy(tag: "Notification") as! SwitchRow)
            row.cell.switchControl.setOn(isAllowed, animated: true)
            row.value = isAllowed
            
            break
        case .locationWhenInUse :
            let isAllowed = Location.checkPermission()
            Location.appGrated = isAllowed
            let row = (form.rowBy(tag: "Location") as! SwitchRow)
            row.cell.switchControl.setOn(isAllowed, animated: true)
            row.value = isAllowed
            break
        default:
            break
        }
        
        
    }
    
    func didAllowPermission(permission: SPRequestPermissionType) {
        switch permission {
        case .notification:
            NotificationHelper.appGrated = true
            break
        case .locationWhenInUse :
            Location.appGrated = true
            break
        default:
            break
        }
    }
    
    func didDeniedPermission(permission: SPRequestPermissionType) {
        switch permission {
        case .notification:
            NotificationHelper.appGrated = false
            break
        case .locationWhenInUse :
            Location.appGrated = false
            break
        default:
            break
        }
    }
    
    func didSelectedPermission(permission: SPRequestPermissionType) {
        
    }
}
