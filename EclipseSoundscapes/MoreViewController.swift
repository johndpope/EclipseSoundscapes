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
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(r: 33, g: 33, b: 33)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationItem.title = "About Us"
        
        
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.contentInset = UIEdgeInsetsMake((self.navigationController?.navigationBar.frame.height)! + (self.navigationController?.navigationBar.frame.origin.y)! + 20, 0, 0, 0)
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake((self.navigationController?.navigationBar.frame.height)! + (self.navigationController?.navigationBar.frame.origin.y)! + 20, 0, 0, 0)
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
                switch UIDevice.current.userInterfaceIdiom {
                case .pad:
                    header.height = {self.view.frame.width * 9 / 16}
                default:
                    break
                }
                
                $0.header = header
            }
            
            +++ TextAreaRow(){
                $0.textAreaHeight = TextAreaHeight.dynamic(initialTextViewHeight: 65)
                $0.cell.layer.borderColor = UIColor.clear.cgColor
                $0.cell.textView.isEditable = false
                $0.cell.isUserInteractionEnabled = false
                }.cellUpdate({ (cell, row) in
                    cell.textView.text = "From the Smithsonian Astrophysics Observatory and NASA’s Heliophysics Education Consortium, The Eclipse Soundscapes Project uses sound to create a multisensory experience of astronomical events such as eclipses. With this app, and an additional citizen science project to record changing environmental sounds during eclipses, Eclipse Soundscapes aims to engage all learners with astrophysics, including people who are blind or visually impaired. For more information, visit eclipsesoundscapes.org."
                    cell.textView.textAlignment = .center
                    cell.accessibilityLabel = cell.textView.text
                    cell.accessibilityTraits = UIAccessibilityTraitStaticText
                    cell.textView.isAccessibilityElement = false
                    cell.textView.font = UIFont.getDefautlFont(.meduium, size: 13)
                })
            
            <<< ButtonRow("How to use the Rumble Map"){ (row: ButtonRow) -> Void in
                row.title = row.tag
                row.cell.imageView?.image = #imageLiteral(resourceName: "rumbleTouch")
                row.presentationMode = .presentModally(controllerProvider: ControllerProvider.callback { return IntructionsViewController(){ _ in } }, onDismiss: nil)
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
            
            <<< ButtonRow("Future Eclipses Supported by this app"){ (row: ButtonRow) -> Void in
                row.title = row.tag
                row.cell.imageView?.image = #imageLiteral(resourceName: "events_icon").withRenderingMode(.alwaysTemplate)
                row.cell.imageView?.tintColor = Color.eclipseOrange
                row.presentationMode = .segueName(segueName: "Future", onDismiss: nil)
                }.cellUpdate({ (cell, _) in
                    cell.textLabel?.font = UIFont.getDefautlFont(.meduium, size: 16)
                    cell.textLabel?.adjustsFontSizeToFitWidth = true
                })
            
            
            
            <<< ButtonRow("Open WalkThrough"){ (row: ButtonRow) -> Void in
                row.title = row.tag
                row.cell.imageView?.image = #imageLiteral(resourceName: "manual")
                row.presentationMode = .presentModally(controllerProvider: ControllerProvider.callback { return WalkthroughViewController()
                }, onDismiss: nil)
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
