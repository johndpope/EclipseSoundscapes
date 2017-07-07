//
//  InfoUITableViewCell.swift
//  WhenIsMyEclipse
//
//  Created by Anonymous on 6/29/17.
//  Copyright © 2017 Arlindo Goncalves. All rights reserved.
//

import UIKit

class InfoTableViewCell: UITableViewCell {
    
    let stackView : UIStackView = {
        var sv = UIStackView()
        sv.alignment = UIStackViewAlignment.center
        sv.distribution = .fillEqually
        sv.axis = .horizontal
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    var eventLabel : UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.getDefautlFont(.condensedMedium, size: 14)
        label.text = "Event"
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.textColor = .white
        return label
    }()

    var timeLabel : UILabel = {
        var label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.getDefautlFont(.condensedMedium, size: 14)
        label.text = "Time (UT)"
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    var altLabel : UILabel = {
        var label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.getDefautlFont(.condensedMedium, size: 14)
        label.text = "Alt"
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    var aziLabel : UILabel = {
        var label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.getDefautlFont(.condensedMedium, size: 14)
        label.text = "Azi"
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCell()
    }
    
    func setupCell() {
        backgroundColor = .clear
        self.addSubview(stackView)
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        
        stackView.addArrangedSubview(eventLabel)
        stackView.addArrangedSubview(timeLabel)
        stackView.addArrangedSubview(altLabel)
        stackView.addArrangedSubview(aziLabel)
    }
    
    func eventRow(_ event: EclipseEvent) {
        eventLabel.text = event.name + ":"
        eventLabel.accessibilityLabel = "Event \(event.name),"
        timeLabel.text = event.time
        timeLabel.accessibilityLabel = "Universal Time \(event.time),"
        altLabel.text = event.alt
        altLabel.accessibilityLabel = "Altitude \(event.alt),"
        aziLabel.text = event.azi
        aziLabel.accessibilityLabel = "Azimuth \(event.azi)"
    }
    
    func changeTextColor(isWhite flag: Bool) {
        if flag {
            eventLabel.textColor = .white
            timeLabel.textColor = .white
            altLabel.textColor = .white
            aziLabel.textColor = .white
        } else {
            eventLabel.textColor = .black
            timeLabel.textColor = .black
            altLabel.textColor = .black
            aziLabel.textColor = .black
        }
    }
}
