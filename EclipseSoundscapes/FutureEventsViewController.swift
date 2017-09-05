//
//  FutureEventsViewController.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 8/4/17.
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

class FutureEventsViewController : FormViewController, TypedRowControllerType {
    
    var row: RowOf<String>!
    var onDismissCallback: ((UIViewController) -> ())?
    
    lazy var headerView : ShrinkableHeaderView = {
        let view = ShrinkableHeaderView(title: "Eclipses We Support", titleColor: .black)
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
    
    
    var futureEvents = [FutureEvent]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
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

        for event in futureEvents {
            addEvent(event)
        }
        
        let section = form.allSections[0]
        section.header = HeaderFooterView<UIView>(HeaderFooterProvider.class)
        section.header?.height = {CGFloat.leastNormalMagnitude}
    }
    
    func load() {
        guard let file = Bundle.main.url(forResource: "Future_Eclipses", withExtension: ".json") else {
            return
        }
        do {
            let data = try Data(contentsOf: file)
            let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [Dictionary<String, Any>]
            
            guard let unwrapedJson = json else {
                return
            }
            
            for object in unwrapedJson {
                futureEvents.append(FutureEvent(date: object["Date"] as? String, time: object["Time"] as? String, type: object["Type"] as? String, feature: object["Features"] as? String))
            }
            
        } catch {
            return
        }
    }
    
    func addEvent(_ event: FutureEvent) {
        form
            +++ EventRow { row in
                row.value = event
                if let cell = row.cell {
                    cell.dateLabel.alpha = 0
                    cell.timeLabel.alpha = 0
                    cell.typeLabel.alpha = 0
                    cell.featureLabel.alpha = 0
                    UIView.animate(withDuration: 2.0, animations: { [weak cell = cell] in
                        cell?.dateLabel.alpha = 1
                        cell?.timeLabel.alpha = 1
                        cell?.typeLabel.alpha = 1
                        cell?.featureLabel.alpha = 1
                    })
                    cell.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1)
                    UIView.animate(withDuration: 1.0, animations: { [weak cell = cell] in
                        cell?.layer.transform = CATransform3DIdentity
                    })
                }
            }
    }

    
    @objc private func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
