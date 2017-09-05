//
//  LicenseViewController.swift
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

class LicenseViewController : FormViewController, TypedRowControllerType {
    
    var row: RowOf<String>!
    var onDismissCallback: ((UIViewController) -> ())?
    
    lazy var headerView : ShrinkableHeaderView = {
        let view = ShrinkableHeaderView(titleColor: .black)
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
    
    
    var libraries : [OpenSourceLibrary] = [OpenSourceLibrary.init(title: "Eclipse Soundscapes", license: "LICENSE")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        initializeForm()
        
        headerView.titleText = "Eclipse Soundscapes v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "")"
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
        
        for lib in libraries {
            form
                +++ Section() { section in
                    var header = HeaderFooterView<UIView>(HeaderFooterProvider.class)
                    header.onSetupView = { view, section in
                        let label = UILabel()
                        label.textColor = .black
                        label.text = lib.title
                        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                        label.font = UIFont.getDefautlFont(.condensedMedium, size: 16)
                        view.addSubview(label)
                    }
                    header.height = {20}
                    section.header = header
                }
                <<< TextAreaRow(){
                    $0.textAreaHeight = TextAreaHeight.dynamic(initialTextViewHeight: 65)
                    $0.cell.layer.borderColor = UIColor.clear.cgColor
                    $0.cell.textView.isEditable = false
                    $0.cell.isUserInteractionEnabled = false
                    }.cellUpdate({ (cell, row) in
                        cell.textView.textContainerInset = UIEdgeInsetsMake(20, 20, 10, 20)
                        cell.textView.layer.borderColor = UIColor(r: 64, g: 97, b: 126).cgColor
                        cell.textView.layer.borderWidth = 1.0
                        cell.textView.backgroundColor = UIColor(r: 249, g: 249, b: 249)
                        cell.textView.text = lib.license
                        cell.accessibilityLabel = cell.textView.text
                        cell.accessibilityTraits = UIAccessibilityTraitStaticText
                        cell.textView.isAccessibilityElement = false
                        cell.textView.font = UIFont.getDefautlFont(.meduium, size: 12)
                    })
        }
        
    }
    
    @objc private func close() {
        self.dismiss(animated: true, completion: nil)
    }
}

