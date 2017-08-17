//
//  InfoCell.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 7/25/17.
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

final class InfoCell: Cell<EclipseEvent>, CellType {
    
    @IBOutlet weak var stackView: UIStackView!
    
    let eventLabel : UILabel = {
        let label = UILabel()
        label.text = "Event"
        label.font = UIFont.getDefautlFont(.condensedMedium, size: 15)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    let localTimeLabel : UILabel = {
        let label = UILabel()
        label.text = "Local Time"
        label.font = UIFont.getDefautlFont(.condensedMedium, size: 15)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    let timeLabel : UILabel = {
        let label = UILabel()
        label.text = "Time (UT)"
        label.accessibilityLabel = "Universal Time"
        label.font = UIFont.getDefautlFont(.condensedMedium, size: 15)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setup() {
        super.setup()
        selectionStyle = .none
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 5
    
        stackView.addArrangedSubview(eventLabel)
        stackView.addArrangedSubview(localTimeLabel)
        stackView.addArrangedSubview(timeLabel)
    }
    func set(_ event: EclipseEvent? , atUserLocation : Bool = true) {
        guard let event = event else {
            return
        }
        eventLabel.text = event.name + ":"
        eventLabel.accessibilityLabel = "Event from \(atUserLocation ? "your" : "closest") location, \(event.name),"
        
        let localTime = Utility.UTCToLocal(date: event.time)
        localTimeLabel.text = localTime
        localTimeLabel.accessibilityLabel = "Local Time, \(localTime),"
        
        timeLabel.text = event.time
        timeLabel.accessibilityLabel = "Universal Time, \(event.time),"
    }
    
    func toggleAccessibility(_ onOff : Bool, atUserLocation : Bool = true) {
        if !onOff {
            self.accessibilityLabel = "Events at \(atUserLocation ? "your" : "closest") location are below"
            self.accessibilityHint = "Events include \(atUserLocation ? "your" : "closest location's") local time and Universal Time"
        }
        eventLabel.isAccessibilityElement = onOff
        localTimeLabel.isAccessibilityElement = onOff
        timeLabel.isAccessibilityElement = onOff
    }
    
}

final class InfoRow: Row<InfoCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<InfoCell>(nibName: "InfoCell")
    }
}
