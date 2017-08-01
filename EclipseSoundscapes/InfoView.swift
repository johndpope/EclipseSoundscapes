//
//  InfoView.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 7/5/17.
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

class InfoView: UIView {
    
    var cellId = "InfoCell"
    var timeGenerator : EclipseTimeGenerator! {
        didSet {
            setText()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
    }
    
    var height : CGFloat {
        return self.eclipseTypeLabel.frame.height + self.locationlabel.frame.height + self.tableView.frame.height + self.dateLabel.frame.height + self.magnitudeLabel.frame.height + self.durationLabel.frame.height + self.coverageLabel.frame.height
    }
    
    
    
    var eclipseTypeLabel : UILabel = {
        var label = UILabel()
        label.font = UIFont.getDefautlFont(.bold, size: 22)
        label.textAlignment = .center
        label.textColor = .white
        label.accessibilityTraits |= UIAccessibilityTraitHeader | UIAccessibilityTraitStaticText
        return label
    }()
    
    var locationlabel : UILabel = {
        var label = UILabel()
        label.font = UIFont.getDefautlFont(.condensedMedium, size: 14)
        label.textAlignment = .center
        label.textColor = .white
        label.accessibilityTraits |= UIAccessibilityTraitStaticText
        return label
    }()
    
    var durationLabel : UILabel = {
        var label = UILabel()
        label.font = UIFont.getDefautlFont(.condensedMedium, size: 14)
        label.textAlignment = .center
        label.textColor = .white
        label.accessibilityTraits |= UIAccessibilityTraitStaticText
        return label
    }()
    
    var magnitudeLabel : UILabel = {
        var label = UILabel()
        label.font = UIFont.getDefautlFont(.condensedMedium, size: 14)
        label.textAlignment = .center
        label.textColor = .white
        label.accessibilityTraits |= UIAccessibilityTraitStaticText
        return label
    }()
    
    var coverageLabel : UILabel = {
        var label = UILabel()
        label.font = UIFont.getDefautlFont(.condensedMedium, size: 14)
        label.textAlignment = .center
        label.textColor = .white
        label.accessibilityTraits |= UIAccessibilityTraitStaticText
        return label
    }()
    
    var dateLabel : UILabel = {
        var label = UILabel()
        label.font = UIFont.getDefautlFont(.condensedMedium, size: 14)
        label.textAlignment = .center
        label.textColor = .white
        label.accessibilityTraits |= UIAccessibilityTraitStaticText
        return label
    }()
    
    var tableView: UITableView = {
        var tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.layer.cornerRadius = 2.5
        tv.clipsToBounds = true
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        tv.allowsSelection = false
        return tv
    }()
    
    var eclipseInfo : [EclipseEvent]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureContent() {
        
        tableView.register(InfoTableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.delegate = self
        tableView.dataSource = self
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        stackView.alignment = .center
        
        stackView.addArrangedSubview(eclipseTypeLabel)
        stackView.addArrangedSubview(locationlabel)
        stackView.addArrangedSubview(magnitudeLabel)
        stackView.addArrangedSubview(durationLabel)
        stackView.addArrangedSubview(coverageLabel)
        stackView.addArrangedSubview(dateLabel)
        
        addSubview(tableView)
        addSubview(stackView)
        stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -10).isActive = true
        
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
//        tableView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        tableView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    func setText() {
        
        var typeStr = ""
        switch timeGenerator.eclipseType {
        case .none:
            eclipseTypeLabel.text = "No Solar Eclipse"
            tableView.isHidden = true
            layoutIfNeeded()
            return
        case .partial:
            typeStr = "Partial Solar Eclipse"
            eclipseInfo = [timeGenerator.contact1, timeGenerator.contactMid, timeGenerator.contact4]
            self.magnitudeLabel.text = "Magnitude: " + timeGenerator.magnitude!
            self.durationLabel.text = nil
            self.coverageLabel.text =  nil
            break
        case .full :
            typeStr = "Total Solar Eclipse"
            eclipseInfo = [timeGenerator.contact1, timeGenerator.contact2, timeGenerator.contactMid, timeGenerator.contact3, timeGenerator.contact4]
            self.magnitudeLabel.text = "Magnitude: " + timeGenerator.magnitude!
            self.durationLabel.text = "Duration of Totality: " + timeGenerator.duration!
            self.coverageLabel.text =  "Obscuration: " + timeGenerator.coverage
            break
        }
        eclipseTypeLabel.text = typeStr
        locationlabel.text = "Latitude: \(timeGenerator.latString), Longitude: \(timeGenerator.lonString)"
        dateLabel.text = "Date: \(timeGenerator.contact1.date)"
    }
    
    func clear() {
        eclipseTypeLabel.text = nil
        locationlabel.text = nil
        magnitudeLabel.text = nil
        durationLabel.text = nil
        coverageLabel.text = nil
        dateLabel.text = nil
        
        self.eclipseInfo = nil
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    var header : UIView =  {
        let header = UIView()
        header.isAccessibilityElement = false
        header.accessibilityElementsHidden = true
        header.backgroundColor = UIColor.init(r: 214, g: 93, b: 18)
        header.layer.cornerRadius = 2.5
        
        let eventLabel = UILabel()
        eventLabel.text = "Event"
        eventLabel.font = UIFont.getDefautlFont(.condensedMedium, size: 15)
        eventLabel.textColor = .white
        eventLabel.textAlignment = .center
        
        let timeLabel = UILabel()
        timeLabel.text = "Time (UT)"
        timeLabel.accessibilityLabel = "Universal Time"
        timeLabel.font = UIFont.getDefautlFont(.condensedMedium, size: 15)
        timeLabel.textColor = .white
        timeLabel.textAlignment = .center
        
        let altLabel = UILabel()
        altLabel.text = "Alt"
        altLabel.accessibilityLabel = "Altitude"
        altLabel.font = UIFont.getDefautlFont(.condensedMedium, size: 15)
        altLabel.textColor = .white
        altLabel.textAlignment = .center
        
        let aziLabel = UILabel()
        aziLabel.text = "Azi"
        aziLabel.accessibilityLabel = "Azimuth"
        aziLabel.font = UIFont.getDefautlFont(.condensedMedium, size: 15)
        aziLabel.textColor = .white
        aziLabel.textAlignment = .center
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        
        header.addSubview(stackView)
        stackView.bottomAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: header.topAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 10).isActive = true
        stackView.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -10).isActive = true
        
        stackView.addArrangedSubview(eventLabel)
        stackView.addArrangedSubview(timeLabel)
        stackView.addArrangedSubview(altLabel)
        stackView.addArrangedSubview(aziLabel)
        
        return header
    }()
}

extension InfoView : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let info = eclipseInfo else {
            return 0
        }
        return info.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! InfoTableViewCell
        guard let info = eclipseInfo?[indexPath.row] else {
            return cell
        }
        
        cell.eventRow(info)
        return cell
        
    }
}

