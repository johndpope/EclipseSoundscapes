//
//  TapeTaskPiece.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 5/31/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import Foundation

class TapeTaskPiece {
    private var _duration : Double = 0
    private var _error : Error?
    
    var duration : Double {
        return _duration
    }
    
    var error :Error? {
        return _error
    }
    
    init(duration: Double, error: Error? = nil) {
        self._duration = duration
        self._error = error
    }
}
