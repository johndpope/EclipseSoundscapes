//
//  NetworkManager.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 5/23/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseDatabase

/// Network functionality with Firebase Storeage and RealtimeDB
/// Uploader
/// Downloader


/// Wrapper for Error specifically for Network Errors
protocol NetworkErrorProtocol: Error {
    
    var localizedTitle: String { get }
    var localizedDescription: String { get }
    var code: Int { get }
}


/// Network Error Object
struct NetworkError: AuthErrorProtocol {
    
    var localizedTitle: String
    var localizedDescription: String
    var code: Int
    
    init(localizedTitle: String?, localizedDescription: String, code: Int) {
        self.localizedTitle = localizedTitle ?? "Error"
        self.localizedDescription = localizedDescription
        self.code = code
    }
}


/// Upload/Download Status keys
@objc enum NetworkStatus : Int {
    case audioSuccess
    case jsonSuccess
    case realtimeSuccess
    case error
    case cancelled
    case paused
}


let CitizenScientistsDirectory = "CitizenScientists"
let LocationDirectory = "Locations"
let AllRecordings = "Recordings"




