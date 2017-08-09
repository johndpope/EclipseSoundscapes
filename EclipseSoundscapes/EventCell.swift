//
//  EventCell.swift
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

class FutureEvent: Equatable {
    var date : String?
    var time: String?
    var type: String?
    var feature: String?
    
    init(date : String?, time: String?, type: String?, feature: String?) {
        self.date = date
        self.time = time
        self.type = type
        self.feature = feature
    }
}

func ==(lhs: FutureEvent, rhs : FutureEvent) -> Bool {
    return lhs.date == rhs.date
}

final class EventCell: Cell<FutureEvent>, CellType {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var featureLabel: UILabel!
    
    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setup() {
        super.setup()
        selectionStyle = .none
        dateLabel.font = UIFont.getDefautlFont(.meduium, size: 15)
        timeLabel.font = UIFont.getDefautlFont(.meduium, size: 15)
        typeLabel.font = UIFont.getDefautlFont(.meduium, size: 15)
        featureLabel.font = UIFont.getDefautlFont(.meduium, size: 15)
        
        height = { return UITableViewAutomaticDimension }
        
        self.accessibilityTraits = UIAccessibilityTraitHeader
    }
    
    override func update() {
        super.update()
        if let event = row.value {
            dateLabel.text = "Date: \( event.date ?? "")"
            timeLabel.text = "Time: \( event.time ?? "")"
            typeLabel.text = "Type: \( event.type ?? "")"
            featureLabel.text = "Features: \( event.feature ?? "")"
        }
    }
}

final class EventRow: Row<EventCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<EventCell>(nibName: "EventCell")
    }
}
