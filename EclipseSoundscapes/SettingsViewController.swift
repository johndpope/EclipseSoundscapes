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
import Material

class SettingsViewController : FormViewController, TypedRowControllerType {
    
    var row: RowOf<String>!
    var onDismissCallback: ((UIViewController) -> ())?
    
    lazy var headerView : ShrinkableHeaderView = {
        let view = ShrinkableHeaderView(title: "Settings", titleColor: .black)
        view.backgroundColor = Color.NavBarColor
        view.maxHeaderHeight = 60
        view.isShrinkable = false
        return view
    }()
    
    lazy var backBtn : UIButton = {
        var btn = UIButton(type: .system)
        btn.addSqueeze()
        btn.setImage(#imageLiteral(resourceName: "left-small").withRenderingMode(.alwaysTemplate), for: .normal)
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(close), for: .touchUpInside)
        btn.accessibilityLabel = "Back"
        return btn
    }()
    
    var currentSetting : PermissionType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        initializeForm()
    }
    
    func setupViews() {
        view.backgroundColor = headerView.backgroundColor
        view.addSubview(headerView)
        
        headerView.headerHeightConstraint = headerView.anchor(topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0,widthConstant: 0, heightConstant: headerView.maxHeaderHeight).last!
        
        headerView.addSubviews(backBtn)
        backBtn.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        backBtn.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 10).isActive = true
        
        tableView.anchorWithConstantsToTop(headerView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
    }
    
    @objc private func initializeForm() {
        
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
        }
        
        
    }
}
