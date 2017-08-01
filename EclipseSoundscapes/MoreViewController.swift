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
            
            +++ Section("About Us") { section in
                var header = HeaderFooterView<UIView>(HeaderFooterProvider.class)
                header.onSetupView = { view, section in
                    let label = InsetLabel()
                    label.textColor = .white
                    label.text = "About Us"
                    label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    label.font = UIFont.getDefautlFont(.condensedMedium, size: 14)
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
                    cell.textView.text = "On August 21, 2017, millions of people will view a total solar eclipse as it passes through the United States. However, for the visually impaired, or others who are unable to see the eclipse with their own eyes, the Eclipse Soundscapes Project delivers a multisensory experience of this exciting celestial event. The project, from NASA’s Heliophysics Education Consortium, will include illustrated audio descriptions of the eclipse in real time, recordings of the changing environmental sounds during the eclipse, and an interactive “rumble map” app that will allow users to visualize the eclipse through touch."
                    cell.accessibilityLabel = cell.textView.text
                    cell.accessibilityTraits = UIAccessibilityTraitStaticText
                    cell.textView.isAccessibilityElement = false
                    cell.textView.font = UIFont.getDefautlFont(.meduium, size: 13)
                })
            <<< ButtonRow("How to use the Rumble Map"){ (row: ButtonRow) -> Void in
                row.title = row.tag
                row.cell.imageView?.image = #imageLiteral(resourceName: "manual")
                row.presentationMode = .show(controllerProvider: ControllerProvider.callback { return IntructionsViewController(){ _ in } }, onDismiss: nil)
                }.cellUpdate({ (cell, _) in
                    cell.textLabel?.font = UIFont.getDefautlFont(.meduium, size: 16)
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
        
        +++ Section()
    }
    
    func setDefaults() {
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(20, 0, 0, 0)
        self.tableView.backgroundColor = UIColor(r: 75, g: 75, b: 75)
        view.backgroundColor = .black
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

class InsetLabel: UILabel {
    let topInset = CGFloat(10)
    let bottomInset = CGFloat(10)
    let leftInset = CGFloat(10)
    let rightInset = CGFloat(10)
    
    override func drawText(in rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override public var intrinsicContentSize: CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize
        intrinsicSuperViewContentSize.height += topInset + bottomInset
        intrinsicSuperViewContentSize.width += leftInset + rightInset
        return intrinsicSuperViewContentSize
    }
}
