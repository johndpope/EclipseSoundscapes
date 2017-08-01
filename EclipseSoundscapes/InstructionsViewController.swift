//
//  InstructionsViewController.swift
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

import UIKit
import Eureka

class IntructionsViewController : UIViewController, TypedRowControllerType {
    
    var row: RowOf<String>!
    var onDismissCallback: ((UIViewController) -> ())?
    
    lazy var backBtn: UIButton = {
        var btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "left-small").withRenderingMode(.alwaysTemplate), for: .normal)
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(close), for: .touchUpInside)
        return btn
    }()
    
    var cell : PageCell!
    
    let page = Page(title: "Rumble Map", message: "Our Rumble Map Intructions are coming soon...", imageName: "Soundscapes-RumbleMap")
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(_ callback: ((UIViewController) -> ())?) {
        super.init(nibName: nil, bundle: nil)
        onDismissCallback = callback
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cell = PageCell()
        cell.page = page
        
        view.addSubview(cell)
        view.addSubview(backBtn)
        
        cell.anchorToTop(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        backBtn.anchorWithConstantsToTop(topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 0)
    }
    
    func close() {
        self.dismiss(animated: true, completion: nil)
    }
}
