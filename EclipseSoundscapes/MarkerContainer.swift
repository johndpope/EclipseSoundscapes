//
//  MarkerContainer.swift
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

class MarkerContainer : NSObject {
    
    private var container : Dictionary<CGFloat, Dictionary<CGFloat, Bool>>!
    
    var lastPoint : CGPoint?
    
    init(frame: CGRect) {
        super.init()
        container = Dictionary<CGFloat, Dictionary<CGFloat, Bool>>()
        
        for column in stride(from: 0.0, through: frame.height+1, by: 1.0) {
            var rowDictionary = Dictionary<CGFloat, Bool>()
            for row in stride(from: 0.0, through: frame.width, by: 1.0) {
                rowDictionary.updateValue(false, forKey: row)
            }
            container.updateValue(rowDictionary, forKey: column)
            
        }
    }
    
    func restore(forIndex index: Int) -> Self {
        
        guard let x = UserDefaults.standard.object(forKey: "\(index)rumblePoint-X") as? CGFloat,
            let y = UserDefaults.standard.object(forKey: "\(index)rumblePoint-Y") as? CGFloat else {
                return self
        }
        
        self.insert(CGPoint(x: x, y: y))
        return self
    }
    
    func contains(_ point: CGPoint) -> Bool {
        
        guard let column = container[point.y.rounded()], let flag = column[point.x.rounded()] else {
            return false
        }
        return flag
    }
    
    func insert(_ point: CGPoint) {
        if lastPoint != nil {
            remove(lastPoint!)
        }
        lastPoint = point
        
        let negativeY = point.strideDownY()
        let positiveY = point.strideUpY()
        
        let negativeX = point.strideDownX()
        let positiveX = point.strideUpX()
        
        for i in positiveY where container[i] != nil {
            
            for j in positiveX {
                container[i]!.updateValue(true, forKey: j)
            }
            
            for j in negativeX {
                container[i]!.updateValue(true, forKey: j)
            }
        }
        
        for i in negativeY where container[i] != nil {
            for j in positiveX {
                container[i]!.updateValue(true, forKey: j)
            }
            
            for j in negativeX {
                container[i]!.updateValue(true, forKey: j)
            }
        }
    }
    
    private func remove(_ point: CGPoint) {
        let negativeY = point.strideDownY()
        let positiveY = point.strideUpY()
        
        let negativeX = point.strideDownX()
        let positiveX = point.strideUpX()
        
        for i in positiveY where container[i] != nil {
            
            for j in positiveX {
                container[i]!.updateValue(false, forKey: j)
            }
            
            for j in negativeX {
                container[i]!.updateValue(false, forKey: j)
            }
        }
        
        for i in negativeY where container[i] != nil {
            for j in positiveX {
                container[i]!.updateValue(false, forKey: j)
            }
            
            for j in negativeX {
                container[i]!.updateValue(false, forKey: j)
            }
        }
    }
    
    override var description: String {
        return self.container.description
    }
    
    subscript(index: CGFloat) -> Dictionary<CGFloat, Bool>? {
        get {
            return container[index]
        }
    }
}
