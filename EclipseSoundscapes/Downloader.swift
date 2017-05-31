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

class DownloadTask : StorageDownloadTask {
    
    
    var path : URL?
    
    /// Stop the download task, and attempt to destory the temporary file that contains the downloaded audio file
    ///
    /// - Throws: Error involved with deleting audio file
    func stopDownload()throws {
        super.cancel()
        do {
            if self.path != nil {
                try FileManager.default.removeItem(at: self.path!)
            }
        } catch  {
            throw error
        }
    }
}

class Downloader {
    
    var needsAudio  = true
    var needInfo = true
    
    /// Firebase Storage Object
    fileprivate let storeage = Storage.storage()
    
    /// Firebase RealtimeDB Object
    fileprivate let database = Database.database()
    
    /// RealtimeDB reference
    fileprivate var databaseRef : DatabaseReference?
    
    func downloadInforamtion(withId id : String, completion: @escaping (Dictionary<String,Any>?, Error?) -> Void)-> DownloadTask? {
        let storageRef = storeage.reference().child(CitizenScientistsDirectory).child(id).child(id.appending(".json"))
        
        let downloadTask = storageRef.getData(maxSize: 1024, completion: { (data, error) in
            let trackInfo = ResourceManager.buildInfoFromData(withData: data)
            self.needInfo = false
            completion(trackInfo, error)
        }) as! DownloadTask
        
        
        return downloadTask
    }
    
    func downloadAudio(withId id : String, completion: @escaping (URL?, Error?) -> Void)-> DownloadTask?{
        
        let recordingName = id.appending(FileType)
        let storageRef = storeage.reference().child(CitizenScientistsDirectory).child(id).child(recordingName)
        
        let tempDirectoryPath = FileManager.default.temporaryDirectory.appendingPathComponent(recordingName)
        
        let downloadTask : DownloadTask = storageRef.write(toFile: tempDirectoryPath) { (url, error) in
            self.needsAudio = false
            completion(url, error)
        } as! DownloadTask
        
    
        return downloadTask
    }
}
