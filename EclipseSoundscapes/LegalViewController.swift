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

class LegalViewController : FormViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeForm()
        
        self.navigationItem.title = "Legal"
        self.navigationItem.addSqeuuzeBackBtn(self, action: #selector(close), for: .touchUpInside)
    }
    
    private func initializeForm() {
        
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.contentInset = UIEdgeInsetsMake((self.navigationController?.navigationBar.frame.height)! + (self.navigationController?.navigationBar.frame.origin.y)! + 20, 0, 0, 0)
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake((self.navigationController?.navigationBar.frame.height)! + (self.navigationController?.navigationBar.frame.origin.y)! + 20, 0, 0, 0)
        
        form
            +++ ButtonRow("License"){(row: ButtonRow) -> Void in
                row.title = row.tag
                row.presentationMode = PresentationMode.segueName(segueName: "License", onDismiss: nil)
            }
            <<< ButtonRow("Open Source Libraries"){(row: ButtonRow) -> Void in
                row.title = row.tag
                row.presentationMode = PresentationMode.segueName(segueName: "OpenSourceLibraries", onDismiss: nil)
                
            }
            <<< ButtonRow("Photo Credits"){(row: ButtonRow) -> Void in
                row.title = row.tag
                row.presentationMode = PresentationMode.segueName(segueName: "Photo Credits", onDismiss: nil)
            }
            <<< ButtonRow("Privacy Policy"){(row: ButtonRow) -> Void in
                row.title = row.tag
                row.presentationMode = PresentationMode.segueName(segueName: "PrivacyPolicy", onDismiss: nil)
        }
        
    }
    
    @objc private func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
