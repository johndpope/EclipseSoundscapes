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
    
    var currentSetting : PermissionType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeForm()
        self.navigationItem.title = "Settings"
        
        self.navigationItem.addSqeuuzeBackBtn(self, action: #selector(close), for: .touchUpInside)
    }
    
    @objc private func initializeForm() {
        
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.contentInset = UIEdgeInsetsMake((self.navigationController?.navigationBar.frame.height)! + (self.navigationController?.navigationBar.frame.origin.y)! + 20, 0, 0, 0)
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake((self.navigationController?.navigationBar.frame.height)! + (self.navigationController?.navigationBar.frame.origin.y)! + 20, 0, 0, 0)
        
        form
            +++ SwitchRow("Notification") {
                $0.title = "Notifications"
                $0.value = Permission.isAllowPermission(.notification) && NotificationHelper.appGrated
                }.onChange({ (row) in
                    if let switchOn = row.value {
                        if switchOn {
                            NotificationHelper.appGrated = true
                            if !NotificationHelper.isGranted{
                                self.currentSetting = .notification
                                self.present(PermissionViewController.show(with: [.notification], completion: {
                                    self.didHide()
                                }), animated: true, completion: nil)
                            }
                        } else {
                            NotificationHelper.appGrated = false
                        }
                    }
                    
                })
            <<< SwitchRow("Location") {
                $0.title = "Location"
                $0.value = Permission.isAllowPermission(.locationWhenInUse) && Location.appGrated
                }.onChange({ (row) in
                    if let switchOn = row.value {
                        if switchOn {
                            Location.appGrated = true
                            if !Location.isGranted{
                                self.currentSetting = .locationWhenInUse
                                self.present(PermissionViewController.show(with: [.locationWhenInUse], completion: {
                                    self.didHide()
                                }), animated: true, completion: nil)
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
    
    func didHide() {
        guard let type = currentSetting else {
            return
        }
        switch type {
        case .notification:
            let isAllowed = NotificationHelper.checkPermission()
            let row = (form.rowBy(tag: "Notification") as! SwitchRow)
            row.cell.switchControl.setOn(isAllowed, animated: true)
            row.value = isAllowed
            
            break
        case .locationWhenInUse :
            let isAllowed = Location.checkPermission()
            let row = (form.rowBy(tag: "Location") as! SwitchRow)
            row.cell.switchControl.setOn(isAllowed, animated: true)
            row.value = isAllowed
            break
        default:
            break
        }
        
        
    }
}

//extension SettingsViewController: SPRequestPermissionEventsDelegate {
//

//
//    func didAllowPermission(permission: SPRequestPermissionType) {
//        switch permission {
//        case .notification:
//            NotificationHelper.appGrated = true
//            break
//        case .locationWhenInUse :
//            Location.appGrated = true
//            break
//        default:
//            break
//        }
//    }
//
//    func didDeniedPermission(permission: SPRequestPermissionType) {
//        switch permission {
//        case .notification:
//            NotificationHelper.appGrated = false
//            break
//        case .locationWhenInUse :
//            Location.appGrated = false
//            break
//        default:
//            break
//        }
//    }
//
//    func didSelectedPermission(permission: SPRequestPermissionType) {
//
//    }
//}

