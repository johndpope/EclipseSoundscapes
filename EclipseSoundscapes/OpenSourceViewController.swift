//
//  OpenSourceViewController.swift
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

//  Disclaimer: The logos of NASA, Smithsonian and the Eclipse Soundscapes partners and affiliates are not to be used in any manner that suggests or implies that NASA, Smithsonian or any Eclipse Soundscapes partners and affiliates have endorsed or approved of the activities, products, and/or services of the organization using the Eclipse Soundscapes open source materials, or that NASA, Smithsonian, or any Eclipse Soundscapes partners and affiliates are the source of any such activities, products or services.

import Eureka

class OpenSourceViewController : FormViewController {
    
    
    var libraries : [OpenSourceLibrary] = [OpenSourceLibrary.init(title: "AudioKit", license: "AudioKit-License"),
                                           OpenSourceLibrary.init(title: "BRYXBanner", license: "BRYXBanner-License"),
                                           OpenSourceLibrary.init(title: "Eureka", license: "Eureka-License"),
                                           OpenSourceLibrary.init(title: "SwiftSpinner", license: "SwiftSpinner-License")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeForm()
        
        self.navigationItem.title = "Open Source Libraries"
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "left-small"), style: .plain, target: self, action: #selector(close))
        button.tintColor = .black
        button.accessibilityLabel = "Back"
        self.navigationItem.leftBarButtonItem = button
    }
    
    private func initializeForm() {
        
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.contentInset = UIEdgeInsetsMake((self.navigationController?.navigationBar.frame.height)! + (self.navigationController?.navigationBar.frame.origin.y)! + 20, 0, 0, 0)
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake((self.navigationController?.navigationBar.frame.height)! + (self.navigationController?.navigationBar.frame.origin.y)! + 20, 0, 0, 0)
        
        form
            +++ Section() { section in
                var header = HeaderFooterView<UIView>(HeaderFooterProvider.class)
                header.onSetupView = { view, section in
                    let label = InsetLabel()
                    label.textColor = .black
                    label.text = "Libraries We Use"
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
                    cell.textView.text = "The following sets forth attribution notices for third party software that may be contained in portions of the Eclipse Soundscapes product. We thank the open source community for all of their contributions."
                    cell.accessibilityLabel = cell.textView.text
                    cell.accessibilityTraits = UIAccessibilityTraitStaticText
                    cell.textView.isAccessibilityElement = false
                    cell.textView.font = UIFont.getDefautlFont(.meduium, size: 13)
                })
        
        
        for lib in libraries {
            form
                +++ Section() { section in
                    var header = HeaderFooterView<UIView>(HeaderFooterProvider.class)
                    header.onSetupView = { view, section in
                        let label = InsetLabel()
                        label.textColor = .black
                        label.text = lib.title
                        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                        label.font = UIFont.getDefautlFont(.condensedMedium, size: 16)
                        view.addSubview(label)
                    }
                    
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
    
    func close() {
       _ = self.navigationController?.popViewController(animated: true)
    }
}
