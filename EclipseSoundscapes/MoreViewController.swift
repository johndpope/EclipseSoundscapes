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
        form +++
        Section() {
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
        
    }
    
    func setDefaults() {
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.navigationBar.barTintColor = UIColor(r: 75, g: 75, b: 75)
        self.tableView.backgroundColor = UIColor(r: 75, g: 75, b: 75)
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
    
}
