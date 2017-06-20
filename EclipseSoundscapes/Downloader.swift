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

/// Manages Downloads from Firebase
public class Downloader {
    
    /// Firebase Storage Object
    fileprivate var storeage : Storage!
    
    /// Firebase RealtimeDB Object
    fileprivate var database : Database!
    
    /// RealtimeDB reference
    fileprivate var databaseRef : DatabaseReference?
    
    var path : URL?
    
    init() {
        storeage = Storage.storage()
        database = Database.database()
    }
    
    /// Download Audio Recording from Firebase Storage
    ///
    /// - Parameters:
    ///   - id: Id of Reccording to download, acts as the key
    ///   - completion: completion Block containg the URL of the downloaded
    ///                 Audio Recording or a possible error while downloading
    /// - Returns: Download Task to manage the download and observe its status
    func downloadAudio(withId id : String, completion: @escaping (URL?, Error?) -> Void) -> StorageDownloadTask {
        
        let recordingName = id.appending(FileType)
        let storageRef = storeage.reference().child(CitizenScientistsDirectory).child(id).child(recordingName)
        
        let audioPath = ResourceManager.getDocumentsDirectory().appendingPathComponent(recordingName)
        
        let downloadTask = storageRef.write(toFile: audioPath) { (url, error) in
            guard error == nil else {
                completion(nil, error)
                return
            }
            completion(url, nil)
        }
        
        self.path = audioPath
        
        return downloadTask
    }
    
    /// Download Audio Recording's Inforamtion from Firebase Storage
    ///
    /// - Parameters:
    ///   - id: Id of Recording to download, acts as the key
    ///   - completion: completion Block containg the information of the downloaded Audio Recording or a possible error while downloading
    /// - Returns: Download Task to manage the download and observe its status
    func downloadInforamtion(withId id : String, completion: @escaping (Dictionary<String, Any>?, Error?) -> Void) -> StorageDownloadTask {
        let storageRef = storeage.reference().child(CitizenScientistsDirectory).child(id).child(id.appending(".json"))
        
        let downloadTask = storageRef.getData(maxSize: 1024, completion: { (data, error) in
            let trackInfo = ResourceManager.buildInfoFromData(withData: data)
            guard error == nil else {
                completion(nil, error)
                return
            }
            completion(trackInfo, nil)
        })
        
        return downloadTask
    }
    
    /// Delete a partial Audio download
    /// - Important: Call when a download started but was canceled
    func delete() {
        ResourceManager.deleteFile(atPath: self.path)
    }
    
}
