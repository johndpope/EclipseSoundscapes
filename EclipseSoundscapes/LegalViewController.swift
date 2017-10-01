//
//  LegalViewController.swift
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

class LegalViewController : FormViewController, TypedRowControllerType {
    
    var row: RowOf<String>!
    var onDismissCallback: ((UIViewController) -> ())?
    
    lazy var headerView : ShrinkableHeaderView = {
        let view = ShrinkableHeaderView(title: "Legal", titleColor: .black)
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
    
    private func initializeForm() {

        form
            +++ ButtonRow("License"){(row: ButtonRow) -> Void in
                row.title = row.tag
                row.presentationMode = .presentModally(controllerProvider: ControllerProvider.callback { return LicenseViewController()
                }, onDismiss: nil)
            }
            <<< ButtonRow("Open Source Libraries"){(row: ButtonRow) -> Void in
                row.title = row.tag
                row.presentationMode = .presentModally(controllerProvider: ControllerProvider.callback { return OpenSourceViewController()
                }, onDismiss: nil)
                
            }
            <<< ButtonRow("Photo Credits"){(row: ButtonRow) -> Void in
                row.title = row.tag
                row.presentationMode = .presentModally(controllerProvider: ControllerProvider.callback { return PhotoCreditsViewController()
                }, onDismiss: nil)
            }
            <<< ButtonRow("Privacy Policy"){(row: ButtonRow) -> Void in
                row.title = row.tag
                row.presentationMode = .presentModally(controllerProvider: ControllerProvider.callback { return PrivacyPolicyViewController()
                }, onDismiss: nil)
        }
        
    }
    
    @objc private func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
