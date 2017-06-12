//
//  Uploader.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 5/25/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseDatabase
import GeoFire

/// Manages Uploads from Firebase
public class Uploader {
    
    /// Firebase Storage Object
    private var  storeage : Storage!
    
    /// Firebase RealtimeDB Object
    private var database : Database!
    
    /// RealtimeDB reference
    var databaseRef : DatabaseReference?
    
    /// Recording to upload
    weak var recording : Recording!
    
    init(recording: Recording) {
        storeage = Storage.storage()
        database = Database.database()
        self.recording = recording
    }
    
    /// Store the Recording's Audio Data to Firebase Storage
    ///
    /// - Parameters:
    ///   - url: URL of the audio data ont he
    ///   - id: Recording's Id
    func storeAudio() -> StorageUploadTask? {
        
        guard let id = recording.id else {
            return nil
        }
        
        let url = ResourceManager.recordingURL(id: id)
        
        let storageRef = storeage.reference().child(CitizenScientistsDirectory).child(id).child("\(id)\(FileType)")
        
        let uploadTask = storageRef.putFile(from: url)
        
        return uploadTask
    }
    
    /// Store Recording's extra inforamtion to Firebase Storgae
    ///
    /// - Parameters:
    ///   - id: Recording's Id
    ///   - jsonData: Extra information in JSON format
    func storeInformation() -> StorageUploadTask? {
        
        guard let id = recording.id else {
            return nil
        }
        
        guard let information = ResourceManager.recordingInfo(recording: self.recording) else {
            return nil
        }
        
        let storageRef = storeage.reference().child(CitizenScientistsDirectory).child(id).child("\(id).json")
        
        let uploadTask = storageRef.putData(information)
        
        return uploadTask
    }

    /// Store Information about the recording into the RealtimeDB
    ///
    /// - Parameters:
    ///   - id: Recoding's Information
    ///   - info: Dictionary containg the inforamtion to store
    ///   - completion: optional Completion block possibly containing an error
//    func storeAttributes(withId id : String, info : [String: Any], completion: @escaping (Error?)-> Void){
//        databaseRef = database.reference().child(id)
//        
//        
//        
//        //TODO: Implement some kind of tagging for the Geographical locations based on the Latitude and longitude of the Recording
//        //      - Landscape (City, Rural, Oceananic, etc..)
//        
//        
//        databaseRef?.setValue(info, withCompletionBlock: { (error, ref) in
//            guard error == nil else {
//                //TODO: Handle Error with the upload of the json file
//                completion(error)
//                return
//            }
//            
//            
//            
//            
//            completion(nil)
//        })
//    }
    
     func storeLocation(completion : ((Error?) -> Void)?) {
        guard let id = recording.id else {
            //TODO : Handle Error
            completion?(nil)
            return
        }
        
        let locationRef = database.reference().child(LocationDirectory)
        
        let geoFire = GeoFire(firebaseRef: locationRef)
        
        let location = CLLocation(latitude: recording.latitude, longitude: recording.longitude)
        
        geoFire?.setLocation(location, forKey: id, withCompletionBlock: { (error) in
            guard error == nil else {
                completion?(error)
                return
            }
            completion?(nil)
        })
    }
    
}
