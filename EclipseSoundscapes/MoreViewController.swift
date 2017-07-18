//
//  MoreViewController.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 7/9/17.
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

class MoreViewController : FormViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDefaults()
        initializeForm()
    }
    
    private func initializeForm() {
        form
            +++ Section() {
                var header = HeaderFooterView<LogoView>(.nibFile(name: "SectionHeader", bundle: nil))
                header.onSetupView = { (view, section) -> () in
                    view.imageView.alpha = 0;
                    UIView.animate(withDuration: 2.0, animations: { [weak view] in
                        view?.imageView.alpha = 1
                    })
                    view.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1)
                    UIView.animate(withDuration: 1.0, animations: { [weak view] in
                        view?.layer.transform = CATransform3DIdentity
                    })
                }
                $0.header = header
            }
            
            +++ Section("About Us")
            <<< TextAreaRow(){
                $0.textAreaHeight = TextAreaHeight.dynamic(initialTextViewHeight: 65)
                $0.cell.layer.borderColor = UIColor.clear.cgColor
                $0.cell.textView.isEditable = false
                $0.cell.isUserInteractionEnabled = false
                }.cellUpdate({ (cell, row) in
                    cell.textView.text = "During an eclipse, we gaze in amazement as day becomes night. But, along with the striking visual effects, the soundscape of natural environments changes dramatically."
                    cell.accessibilityLabel = cell.textView.text
                    cell.accessibilityTraits = UIAccessibilityTraitStaticText
                    cell.textView.isAccessibilityElement = false
                    cell.textView.font = UIFont.getDefautlFont(.meduium, size: 13)
                })
            <<< ButtonRow("Our team") { (row: ButtonRow) -> Void in
                row.title = row.tag
                row.cell.imageView?.image = #imageLiteral(resourceName: "team")
                row.presentationMode = .segueName(segueName: "Team", onDismiss: nil)
                }.cellUpdate({ (cell, _) in
                    cell.textLabel?.font = UIFont.getDefautlFont(.meduium, size: 16)
                })
            <<< ButtonRow("Our Partners") { (row: ButtonRow) -> Void in
                row.title = row.tag
                row.cell.imageView?.image = #imageLiteral(resourceName: "partners")
                row.presentationMode = .segueName(segueName: "Partners", onDismiss: nil)
                }.cellUpdate({ (cell, _) in
                    cell.textLabel?.font = UIFont.getDefautlFont(.meduium, size: 16)
                })
            
            +++ Section("More Information")
            
            <<< ButtonRow("How to use this app"){ (row: ButtonRow) -> Void in
                row.title = row.tag
                row.cell.imageView?.image = #imageLiteral(resourceName: "manual")
                row.presentationMode = .segueName(segueName: "Instructions", onDismiss: nil)
                }.cellUpdate({ (cell, _) in
                    cell.textLabel?.font = UIFont.getDefautlFont(.meduium, size: 16)
                })
            <<< ButtonRow("Settings"){ (row: ButtonRow) -> Void in
                row.title = row.tag
                row.cell.imageView?.image = #imageLiteral(resourceName: "settings")
                row.presentationMode = .segueName(segueName: "Settings", onDismiss: nil)
                }.cellUpdate({ (cell, _) in
                    cell.textLabel?.font = UIFont.getDefautlFont(.meduium, size: 16)
                })
            <<< ButtonRow("Legal"){ (row: ButtonRow) -> Void in
                row.title = row.tag
                row.cell.imageView?.image = #imageLiteral(resourceName: "legal")
                row.presentationMode = .segueName(segueName: "Legal", onDismiss: nil)
                }.cellUpdate({ (cell, _) in
                    cell.textLabel?.font = UIFont.getDefautlFont(.meduium, size: 16)
                })
    }
    
    func setDefaults() {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        self.tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        self.tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        self.tableView.backgroundColor = UIColor(r: 75, g: 75, b: 75)
        view.backgroundColor = UIColor(r: 75, g: 75, b: 75)
        URLRow.defaultCellUpdate = { cell, row in cell.textField.textColor = .blue }
    }
    
    
    func showAlert(withTitle title: String, message: String?, actions: [UIAlertAction?]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if actions[0] == nil {
            let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(defaultAction)
        }else {
            for action in actions {
                alert.addAction(action!)
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
