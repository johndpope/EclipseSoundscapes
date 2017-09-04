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
import UIKit

class LicenseViewController : FormViewController, TypedRowControllerType {
    
    var row: RowOf<String>!
    var onDismissCallback: ((UIViewController) -> ())?
    
    var libraries : [OpenSourceLibrary] = [OpenSourceLibrary.init(title: "Eclipse Soundscapes", license: "LICENSE")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeForm()
        
        self.navigationItem.title = "Eclipse Soundscapes v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "")"
        self.navigationItem.addSqeuuzeBackBtn(self, action: #selector(close), for: .touchUpInside)
    }
    
    private func initializeForm() {
        
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.contentInset = UIEdgeInsetsMake((self.navigationController?.navigationBar.frame.height)! + (self.navigationController?.navigationBar.frame.origin.y)! + 20, 0, 0, 0)
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake((self.navigationController?.navigationBar.frame.height)! + (self.navigationController?.navigationBar.frame.origin.y)! + 20, 0, 0, 0)
        
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
    
    func close() {
        _ = self.navigationController?.popViewController(animated: true)
    }
}

