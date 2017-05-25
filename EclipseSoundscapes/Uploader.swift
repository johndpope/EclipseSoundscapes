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


/// Network Delegate Methods for recieving network status updates and progresses
protocol UploadDelegate: NSObjectProtocol {
    
    /// Upload Progress Delegate Method
    ///
    /// - Parameter progress: Progress of upload (0.0 - 1.0)
    func updateProgress(with progress: Float)
    
    
    /// Upload Ended Delegate Method
    ///
    /// - Parameters:
    ///   - status: Status for reason Upload Ended
    ///   - error: Error occured while Upload
    func uploadEnded(with status: NetworkStatus, _ error: Error?)
    
    /// Upload Resumes Delegate Method
    ///
    /// - Parameter error: Error occured while trying to resume
    func uploadResumed(withError error: Error?)
    
}


class Uploader {
    
    weak var delegate: UploadDelegate?
    
    /// Firebase Storage Object
    let storeage = FIRStorage.storage()
    
    
    /// Storage Reference
    var storageRef : FIRStorageReference?
    
    
    /// Upload Task to handle start/stop/pause/resume of uploads
    var uploadTask : FIRStorageUploadTask?
    
    
    /// Firebase RealtimeDB Object
    let database = FIRDatabase.database()
    
    /// RealtimeDB reference
    var databaseRef : FIRDatabaseReference?
    
    var recordingId : String!
    var recordingData : RecordingInfo!
    
    
    var uploadInfo = Dictionary<String, Any>()
    
    
    enum UploadType {
        case json
        case audio
    }
    
    /// Start the Upload of the Recording and its information to Firebase
    ///
    /// - Parameter recording: Recording to upload
    func upload(recording : Recording) {
        
        if delegate == nil {
            print("NO NETWORK DELEGATE. UPLOAD AND DOWNLOAD UPDATES WILL NOT BE GIVEN TO YOU")
        }
        
        guard  let id = recording.id else {
            //TODO: Throw Error to user if the recording does not exist .... Will Always exist except for clear of local memory
            return
        }
        
        recordingId = id
        
        guard let data = ResourceManager.manager()?.recordingInfo(recording: recording, debug: true) else {
            //TODO: Throw Error to user if there wsa an error building the json
            return
        }
        
        recordingData = data
        
        let url = recordingData.url
        
        storeAudio(withURL: url, id: recordingId)
    }
    
    func pauseUpload(){
        if uploadTask != nil {
            uploadTask?.pause()
        }
    }
    
    func resumeUpload(){
        if uploadTask != nil {
            uploadTask?.resume()
        }
    }
    
    func stopUpload(){
        if uploadTask != nil {
            uploadTask?.cancel()
        }
    }
    
    
    /// Store the Recording's Audio Data to Firebase Storage
    ///
    /// - Parameters:
    ///   - url: URL of the audio data ont he
    ///   - id: Recording's Id
    fileprivate func storeAudio(withURL url: URL, id: String){
        
        storageRef = storeage.reference().child(DIRECTORY).child(id).child("\(id)\(AudioManager.FileType)")
        
        
        uploadTask = storageRef?.putFile(url)
        observeUpload(withType: .audio)
    }
    
    
    /// Store Recording's extra inforamtion to Firebase Storgae
    ///
    /// - Parameters:
    ///   - id: Recording's Id
    ///   - jsonData: Extra information in JSON format
    fileprivate func storeJSON(withID id: String, jsonData : Data){
        
        storageRef = storeage.reference().child(DIRECTORY).child(id).child("\(id).json")
        
        uploadTask = storageRef?.put(jsonData)
        observeUpload(withType: .json)
    }
    
    
    
    /// Store Information about the recording into the RealtimeDB
    ///
    /// - Parameters:
    ///   - id: Recoding's Information
    ///   - info: Dictionary containg the inforamtion to store
    ///   - completion: optional Completion block possibly containing an error
    fileprivate func storeRealTimeDB(withId id : String, info : [String: Any], completion: @escaping (Error?)-> Void){
        databaseRef = database.reference().child(id)
        
        databaseRef?.setValue(info, withCompletionBlock: { (error, ref) in
            guard error == nil else {
                //TODO: Handle Error with the upload of the json file
                completion(error)
                return
            }
            
            
            //TODO: Implement some kind of tagging for the Geographical locations based on the Latitude and longitude of the Recording
            //      - Landscape (City, Rural, Oceananic, etc..)
            
            
            
            
            completion(nil)
        })
    }
    
     func storeReference(reference: [String: String], completion:  ((Error?)-> Void)?) {
        databaseRef = database.reference().child("All_Recordings")
        
        databaseRef?.setValue(reference, withCompletionBlock: { (error, ref) in
            guard error == nil else {
                //TODO: Handle Error with the upload of the json file
                completion?(error)
                return
            }
            completion?(nil)
        })
    }
    
    
    
    /// Observe Upload Tasks
    ///
    /// - Parameter type: Current type of upload, Audio Data or JSON
    fileprivate func observeUpload(withType type: UploadType) {
        uploadTask?.observe(.progress, handler: { (snapshot) in
            let progress = Float(snapshot.progress!.completedUnitCount)/Float((snapshot.progress?.totalUnitCount)!)
            if !progress.isNaN {
                self.delegate?.updateProgress(with: progress)
            }
        })
        
        uploadTask?.observe(.success, handler: { (snapshot) in
            self.uploadSucessObserver(withType: type, snapshot: snapshot)
        })
        
        uploadTask?.observe(.resume, handler: { (snapshot) in
            self.resumeUploadObserver(withType: type, snapshot: snapshot)
        })
        
        uploadTask?.observe(.failure, handler: { (snapshot) in
            self.stopUploadObserver(withType: type, snapshot: snapshot)
        })
        
        uploadTask?.observe(.unknown, handler: { (snapshot) in
            self.stopUploadObserver(withType: type, snapshot: snapshot)
        })
        uploadTask?.observe(.pause, handler: { (snapshot) in
            self.pauseUploadObserver(withType: type, snapshot: snapshot)
        })
        
    }
    
    fileprivate func uploadSucessObserver(withType type: UploadType, snapshot: FIRStorageTaskSnapshot){
        if let downloadUrl = snapshot.metadata?.downloadURL()?.absoluteString{
            switch type {
            case .audio:
                
                uploadInfo.updateValue(downloadUrl, forKey: "audioUrl")
                
                self.delegate?.uploadEnded(with: .audioSuccess, nil)
                self.storeJSON(withID: self.recordingId, jsonData: self.recordingData.data)
                
                break
                
            case .json:
                
                
                uploadInfo.updateValue(downloadUrl, forKey: "jsonUrl")
                
                self.delegate?.uploadEnded(with: .jsonSuccess, nil)
                
                self.storeRealTimeDB(withId: self.recordingId, info: uploadInfo, completion: { (error) in
                    //Handle Error
                    self.delegate?.uploadEnded(with: .realtimeSuccess, error)
                })
                
                break
            }
            
        }
        
    }
    
    fileprivate func stopUploadObserver(withType type: UploadType, snapshot: FIRStorageTaskSnapshot){
        
        if let error = snapshot.error {
            self.delegate?.uploadEnded(with: .error, error)
            return
        }
        delegate?.uploadEnded(with: .error, nil)
    }
    
    fileprivate func pauseUploadObserver(withType type: UploadType, snapshot: FIRStorageTaskSnapshot) {
        //TODO: Implement Pause
        if let error = snapshot.error {
            self.delegate?.uploadEnded(with: .paused, error)
            return
        }
        
        delegate?.uploadEnded(with: .paused, nil)
    }
    
    fileprivate func resumeUploadObserver(withType type: UploadType, snapshot: FIRStorageTaskSnapshot){
        //TODO: Implement Resume
        
        if let error = snapshot.error {
            self.delegate?.uploadResumed(withError: error)
            return
        }
        
        delegate?.uploadResumed(withError: nil)
    }
}
