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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeForm()
        
        self.navigationItem.title = "Settings"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
    }
    
    private func initializeForm() {
        form
            +++ SwitchRow() {
                $0.title = "Notifications"
                $0.value = SPRequestPermission.isAllowPermission(.notification)
                }.onChange({ (row) in
                    if let flag = row.value {
                        if flag {
                            if !SPRequestPermission.isAllowPermission(.notification) {
                                SPRequestPermission.dialog.interactive.present(on: self, with: [.notification])
                            } else {
                                
                            }
                        } else {
                            
                        }
                    }
                })
            <<< SwitchRow() {
                $0.title = "Location"
                $0.value = SPRequestPermission.isAllowPermission(.locationWhenInUse) && Location.isGranted
                }.onChange({ (row) in
                    if let flag = row.value {
                        if flag {
                            if !SPRequestPermission.isAllowPermission(.locationWhenInUse) {
                                SPRequestPermission.dialog.interactive.present(on: self, with: [.locationWhenInUse])
                            } else {
                                Location.isGranted = true
                            }
                        } else {
                            Location.isGranted = false
                        }
                    }
                })
    }
    
    @objc private func close() {
        self.dismiss(animated: true, completion: nil)
    }
}
