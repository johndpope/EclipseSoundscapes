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

class FutureEventsViewController : FormViewController {
    
    var futureEvents = [FutureEvent]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
        initializeForm()
        
        self.navigationItem.title = "Eclipses We Support"
        self.navigationItem.addSqeuuzeBackBtn(self, action: #selector(close), for: .touchUpInside)
    }
    
    private func initializeForm() {
        
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.contentInset = UIEdgeInsetsMake((self.navigationController?.navigationBar.frame.height)! + (self.navigationController?.navigationBar.frame.origin.y)! + 20, 0, 0, 0)
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake((self.navigationController?.navigationBar.frame.height)! + (self.navigationController?.navigationBar.frame.origin.y)! + 20, 0, 0, 0)
        
        
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
