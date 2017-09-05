//
//  PhotoCreditsViewController.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 8/1/17.
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

import Material
import Eureka

class PhotoCreditsViewController : FormViewController, TypedRowControllerType {
    
    var row: RowOf<String>!
    var onDismissCallback: ((UIViewController) -> ())?
    
    lazy var headerView : ShrinkableHeaderView = {
        let view = ShrinkableHeaderView(title: "Photo Credits", titleColor: .black)
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
    
    
    let credits = [
                   PhotoCredit(name: "1st Contact", website: "https://xrt.cfa.harvard.edu/xpow/20160315.html", makers: "XRT team(SAO, NASA, JAXA, NAOJ)", photo: #imageLiteral(resourceName: "First Contact")),
                   
                   PhotoCredit(name: "Totality", website: "http://www.zam.fme.vutbr.cz/~druck/eclipse/ecl2006l/Tse2006l_1640_15/0-info.htm", makers: "©2006 Miloslav Druckmüller, Peter Aniol", photo: #imageLiteral(resourceName: "Totality")),
                   
                   PhotoCredit(name: "Bailey's Beads", website: "http://www.zam.fme.vutbr.cz/~druck/Eclipse/Ecl2013u/Tse_2013_bp-7430/0-info.htm", makers: "©2013 Úpice observatory Petr Horálek, Jan Sládeček, ©2014 Miloslav Duckmüller", photo: #imageLiteral(resourceName: "Baily's Beads")),
                   
                   PhotoCredit(name: "Corona", website: "http://www.zam.fme.vutbr.cz/~druck/eclipse/Ecl2002a/Ecl2002_dd_cor/0-info.htm", makers: "©2002 Arne Danielsen, ©2005 Miloslav Druckmüller", photo: #imageLiteral(resourceName: "Corona")),
                   
                   PhotoCredit(name: "Diamond Ring", website: "http://www.zam.fme.vutbr.cz/~druck/Eclipse/Ecl1991m/Ecl1991_rdd_dr/0-info.htm", makers: "©1991 Bill Reyna, ©2005 Hana Druckmüllerová, Miloslav Druckmüller", photo: #imageLiteral(resourceName: "Diamond Ring")),
                   
                   PhotoCredit(name: "Helmet Streamers", website: "http://www.zam.fme.vutbr.cz/~druck/Eclipse/Ecl1994ch/Mid_ecl/0-info.htm", makers: "©1994 Úpice Observatory and Vojtech Rušin, ©2007 Miloslav Druckmüller", photo: #imageLiteral(resourceName: "Helmet Streamers")),
                   
                   PhotoCredit(name: "Prominence", website: "http://www.zam.fme.vutbr.cz/~druck/Eclipse/Ecl1991a/Ecl1991a_in03/0-info.htm", makers: "©1991 Peter Aniol, ©2010 Miloslav Druckmüller", photo: #imageLiteral(resourceName: "Helmet Streamers")),
                   
                   PhotoCredit(name: "Sun as a Star", website: "http://www.zam.fme.vutbr.cz/~druck/Eclipse/Ecl2006th/Tse2006tc_m200_inh30_32_c3/0-info.htm", makers: "©2006 Martin Antoš, Hana Druckmüllerová, Miloslav Druckmüller, ESA/NASA", photo: #imageLiteral(resourceName: "Sun as a Star"))
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        initializeForm()
        
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
        
        for credit in credits {
            addCredit(credit)
        }
        
        let section = form.allSections[0]
        section.header = HeaderFooterView<UIView>(HeaderFooterProvider.class)
        section.header?.height = {CGFloat.leastNormalMagnitude}
    }
    
    func addCredit(_ credit: PhotoCredit) {
        form
            +++ PhotoCreditRow { row in
                row.value = credit
                if let cell = row.cell {
                    cell.photoImageView.alpha = 0
                    cell.nameLabel.alpha = 0
                    cell.websiteBtn.alpha = 0
                    UIView.animate(withDuration: 2.0, animations: { [weak cell = cell] in
                        cell?.photoImageView.alpha = 1
                        cell?.nameLabel.alpha = 1
                        cell?.websiteBtn.alpha = 1
                    })
                    cell.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1)
                    UIView.animate(withDuration: 1.0, animations: { [weak cell = cell] in
                        cell?.layer.transform = CATransform3DIdentity
                    })
                }
            }.onCellSelection({ (cell, row) in
                cell.openWebsite()
            })
    }
    
    
    @objc private func close() {
        self.dismiss(animated: true, completion: nil)
    }
}
