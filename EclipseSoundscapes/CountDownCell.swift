//
//  CountDownCell.swift
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

final class CountDownCell: Cell<Date>, CellType {
    
    @IBOutlet weak var countdownView: CountdownView!
    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setup() {
        super.setup()
        selectionStyle = .none
    }
    
    override func update() {
        super.update()
        if let date = row.value {
            countdownView.startCountdown(date, onCompleted: {
                self.countdownView.isHidden = true
            })
        }
    }
}

final class CountDownRow: Row<CountDownCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<CountDownCell>(nibName: "CountDownCell")
    }
    func set(date : Date){
        value = date
        updateCell()
    }
}
