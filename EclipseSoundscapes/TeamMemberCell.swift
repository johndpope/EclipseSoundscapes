//
//  TeamMemberCell.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 7/24/17.
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

struct TeamMember: Equatable {
    var name: String
    var jobTitle: String
    var bio : String
    var photo: UIImage?
    
    init(name: String, jobTitle: String, bio: String, photo: UIImage?) {
        self.name = name
        self.jobTitle = jobTitle
        self.bio = bio
        self.photo = photo
    }
}

func ==(lhs: TeamMember, rhs: TeamMember) -> Bool {
    return lhs.name == rhs.name
}

final class TeamMemberCell: Cell<TeamMember>, CellType {
    
    @IBOutlet weak var memberImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    
    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setup() {
        super.setup()
        selectionStyle = .none
        nameLabel.font = UIFont.getDefautlFont(.meduium, size: 17)
        jobTitleLabel.font = UIFont.getDefautlFont(.condensedMedium, size: 14)
        memberImageView.contentMode = .scaleAspectFit
        memberImageView.clipsToBounds = true
        height = { return 94 }
        
        self.accessibilityHint = "Touch below for information"
    }
    
    override func update() {
        super.update()
        if let member = row.value {
            nameLabel.text = member.name
            jobTitleLabel.text = member.jobTitle
            if let photo = member.photo {
                memberImageView.image = photo
            }
            
        }
    }
}

final class TeamMemberRow: Row<TeamMemberCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<TeamMemberCell>(nibName: "TeamMemberCell")
    }
}
