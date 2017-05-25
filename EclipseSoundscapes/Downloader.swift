//
//  Downloader.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 5/25/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseDatabase

protocol DownloadDelegate: NSObjectProtocol {
    
    /// Upload Progress Delegate Method
    ///
    /// - Parameter progress: Progress of upload (0.0 - 1.0)
    func downloadProgress(with progress: Float)
    
    
    /// Upload Ended Delegate Method
    ///
    /// - Parameters:
    ///   - status: Status for reason Upload Ended
    ///   - error: Error occured while Upload
    func downloadEnded(with status: NetworkStatus, _ error: Error?)
    
    /// Upload Resumes Delegate Method
    ///
    /// - Parameter error: Error occured while trying to resume
    func downloadResumed(withError error: Error?)
    
}

class Downloader {
    
    weak var delegate: DownloadDelegate?
    
    /// Download Task to handle start/stop/pause/resume of downloads
    var downloadTask : FIRStorageTask?
    
    // MARK: Download Methods
    // TODO: Implement Download Methods
    
    func download(){
        
    }
    
    func stopDownload() {
        
    }
    
    func pauseDownload(snapshot: FIRStorageTaskSnapshot) {
        
    }
    
    func resumeDownload() {
        
    }
}

