//
//  AboutViewController.swift
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
import Material

class AboutViewController : FormViewController {
    
    lazy var headerView : ShrinkableHeaderView = {
        let view = ShrinkableHeaderView(title: "About Us", titleColor: .white)
        view.backgroundColor = Color.lead
        view.textColor = .white
        view.isShrinkable = false
        view.separatorLine.isHidden = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        initializeForm()
    }
    
    func setupViews() {
        self.tableView.backgroundColor = Color.lead
        view.backgroundColor = Color.lead
        
        view.addSubview(headerView)
        
        headerView.headerHeightConstraint = headerView.anchor(topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0,widthConstant: 0, heightConstant: headerView.maxHeaderHeight).last!
        
        tableView.anchorWithConstantsToTop(headerView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
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
                row.presentationMode = .presentModally(controllerProvider: ControllerProvider.callback { return TeamViewController()
                }, onDismiss: nil)
                }.cellUpdate({ (cell, _) in
                    cell.textLabel?.font = UIFont.getDefautlFont(.meduium, size: 16)
                })
            
            <<< ButtonRow("Our Partners") { (row: ButtonRow) -> Void in
                row.title = row.tag
                row.cell.imageView?.image = #imageLiteral(resourceName: "partners")
                row.presentationMode = .presentModally(controllerProvider: ControllerProvider.callback { return PartnersViewController()
                }, onDismiss: nil)
                }.cellUpdate({ (cell, _) in
                    cell.textLabel?.font = UIFont.getDefautlFont(.meduium, size: 16)
                })
            
            <<< ButtonRow("Future Eclipses Supported by this app"){ (row: ButtonRow) -> Void in
                row.title = row.tag
                row.cell.imageView?.image = #imageLiteral(resourceName: "events_icon").withRenderingMode(.alwaysTemplate)
                row.cell.imageView?.tintColor = Color.eclipseOrange
                row.presentationMode = .presentModally(controllerProvider: ControllerProvider.callback { return FutureEventsViewController()
                }, onDismiss: nil)
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
            
            <<< ButtonRow("Give Feedback"){ (row: ButtonRow) -> Void in
                row.title = row.tag
                row.cell.imageView?.image = #imageLiteral(resourceName: "Feedback")
                }.cellUpdate({ (cell, _) in
                    cell.textLabel?.font = UIFont.getDefautlFont(.meduium, size: 16)
                    cell.textLabel?.textColor = .black
                    cell.textLabel?.textAlignment = .left
                }).onCellSelection({ (_, _) in
                    guard let feedbackUrl = URL(string: "https://goo.gl/forms/YdGzNfAlmQDtDWuY2") else {
                        return
                    }
                    Utility.openUrl(feedbackUrl)
                })
            
            <<< ButtonRow("Settings"){ (row: ButtonRow) -> Void in
                row.title = row.tag
                row.cell.imageView?.image = #imageLiteral(resourceName: "settings")
                row.presentationMode = .presentModally(controllerProvider: ControllerProvider.callback { return SettingsViewController()
                }, onDismiss: nil)
                }.cellUpdate({ (cell, _) in
                    cell.textLabel?.font = UIFont.getDefautlFont(.meduium, size: 16)
                })
            <<< ButtonRow("Legal"){ (row: ButtonRow) -> Void in
                row.title = row.tag
                row.cell.imageView?.image = #imageLiteral(resourceName: "legal")
                row.presentationMode = .presentModally(controllerProvider: ControllerProvider.callback { return LegalViewController()
                }, onDismiss: nil)
                }.cellUpdate({ (cell, _) in
                    cell.textLabel?.font = UIFont.getDefautlFont(.meduium, size: 16)
                })
            
            +++ Section()
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
