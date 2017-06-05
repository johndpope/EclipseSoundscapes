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


/// Wrapper class for the StorageDownloadTask that removes partially downloaded file if the download is cancelled
class DownloadTask : StorageDownloadTask {
    
    
    /// Path to the downloaded Audio File
    var path : URL?
    
    
    /// Cancel the download task, and attempt to destory the temporary file that contains the downloaded audio file
    ///
    /// - Throws: Error involved with deleting audio file
    override func cancel() {
        super.cancel()
        do {
            if self.path != nil {
                try FileManager.default.removeItem(at: self.path!)
            }
        } catch  {
            print("File does not exits: \(error.localizedDescription)")
        }
    }
}

class Downloader {
    
    /// Firebase Storage Object
    fileprivate let storeage = Storage.storage()
    
    /// Firebase RealtimeDB Object
    fileprivate let database = Database.database()
    
    /// RealtimeDB reference
    fileprivate var databaseRef : DatabaseReference?
    
    
    /// Download Audio Recording from Firebase Storage
    ///
    /// - Parameters:
    ///   - id: Id of Reccording to download, acts as the key
    ///   - completion: completion Block containg the URL of the downloaded Audio Recording or a possible error while downloading
    /// - Returns: Download Task to manage the download and observe its status
    func downloadAudio(withId id : String, completion: @escaping (URL?, Error?) -> Void)-> DownloadTask?{
        
        let recordingName = id.appending(FileType)
        let storageRef = storeage.reference().child(CitizenScientistsDirectory).child(id).child(recordingName)
        
        let audioPath = FileManager.default.temporaryDirectory.appendingPathComponent(recordingName)
        
        
        let downloadTask : DownloadTask = storageRef.write(toFile: audioPath) { (url, error) in
            guard error == nil else {
                completion(nil, error)
                return
            }
            completion(url, nil)
        } as! DownloadTask
        downloadTask.path = audioPath
        
        
        return downloadTask
    }
    
    
    /// Download Audio Recording's Inforamtion from Firebase Storage
    ///
    /// - Parameters:
    ///   - id: Id of Recording to download, acts as the key
    ///   - completion: completion Block containg the information of the downloaded Audio Recording or a possible error while downloading
    /// - Returns: Download Task to manage the download and observe its status
    func downloadInforamtion(withId id : String, completion: @escaping (Dictionary<String,Any>?, Error?) -> Void)-> DownloadTask? {
        let storageRef = storeage.reference().child(CitizenScientistsDirectory).child(id).child(id.appending(".json"))
        
        let downloadTask = storageRef.getData(maxSize: 1024, completion: { (data, error) in
            let trackInfo = ResourceManager.buildInfoFromData(withData: data)
            guard error == nil else {
                completion(nil, error)
                return
            }
            completion(trackInfo, nil)
        }) as! DownloadTask
        
        
        return downloadTask
    }
    
    
}
