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
}

/// Network Delegate Methods for recieving network status updates and progresses
@objc protocol NetworkDelegate: NSObjectProtocol {
    
    /// Upload Progress Delegate Method
    ///
    /// - Parameter progress: Progress of upload (0.0 - 1.0)
    @objc optional func updateProgress(with progress: Float)
    
    
    /// Upload Ended Delegate Method
    ///
    /// - Parameters:
    ///   - status: Status for reason Upload Ended
    ///   - error: Error occured while Upload
    @objc optional func uploadEnded(with status: NetworkStatus, _ error: Error?)
    
    /// Download Ended Delegate Method
    ///
    /// - Parameters:
    ///   - status: Status for reason download Ended
    ///   - error: Error occured while download
    @objc optional func downloadEnded(with status: NetworkStatus, _ error: Error?)
}



/// Network functionality with Firebase Storeage and RealtimeDB
class NetworkManager {
    
    
    let DIRECTORY = "citizen_scientists"
    
    /// Firebase Storage Object
    let storeage = FIRStorage.storage()
    
    
    /// Storage Reference
    var storageRef : FIRStorageReference?
    
    
    /// Upload Task to handle start/stop/pause/resume of uploads
    var uploadTask : FIRStorageUploadTask?
    
    /// Download Task to handle start/stop/pause/resume of downloads
    var downloadTask : FIRStorageTask?
    
    /// Firebase RealtimeDB Object
    let database = FIRDatabase.database()
    
    
    /// RealtimeDB reference
    var databaseRef : FIRDatabaseReference?
    
    weak var delegate: NetworkDelegate?
    
    
    enum UploadType {
        case json
        case audio
    }
    
    // MARK: Upload Methods
    
    var recordingId : String!
    var recordingData : RecordingInfo!
    
    
    
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
    
    
    /// Store the Recordings Audio Data to Firebase Storage
    ///
    /// - Parameters:
    ///   - url: URL of the audio data ont he
    ///   - id: <#id description#>
    fileprivate func storeAudio(withURL url: URL, id: String){
        
        storageRef = storeage.reference().child(DIRECTORY).child(id).child("\(id)\(AudioManager.FileType)")
        
        
        uploadTask = storageRef?.putFile(url)
        observeUpload(withType: .audio)
    }
    
    fileprivate func storeJSON(withID id: String, jsonData : Data){
        
        storageRef = storeage.reference().child(DIRECTORY).child(id).child("\(id).json")
        
        uploadTask = storageRef?.put(jsonData)
        observeUpload(withType: .json)
    }
    
    
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
    
    
    fileprivate func observeUpload(withType type: UploadType) {
        uploadTask?.observe(.progress, handler: { (snapshot) in
            let progress = Float(snapshot.progress!.completedUnitCount)/Float((snapshot.progress?.totalUnitCount)!)
            if !progress.isNaN {
                self.delegate?.updateProgress!(with: progress)
            }
        })
        
        uploadTask?.observe(.success, handler: { (snapshot) in
            self.uploadSucess(withType: type, snapshot: snapshot)
        })
        
        uploadTask?.observe(.resume, handler: { (snapshot) in
            self.resumeUpload(withType: type, snapshot: snapshot)
        })
        
        uploadTask?.observe(.failure, handler: { (snapshot) in
            self.stopUpload(withType: type, snapshot: snapshot)
        })
        
        uploadTask?.observe(.unknown, handler: { (snapshot) in
            self.stopUpload(withType: type, snapshot: snapshot)
        })
        uploadTask?.observe(.pause, handler: { (snapshot) in
            self.pauseUpload(withType: type, snapshot: snapshot)
        })
        
    }
    
    func uploadSucess(withType type: UploadType, snapshot: FIRStorageTaskSnapshot){
        if let downloadUrl = snapshot.metadata?.downloadURL()?.absoluteString{
            switch type {
            case .audio:
                
                recordingData.json.updateValue(downloadUrl, forKey: "audioUrl")
                self.delegate?.uploadEnded!(with: .audioSuccess, nil)
                self.storeJSON(withID: self.recordingId, jsonData: self.recordingData.data)
                
                break
                
            case .json:
                
                recordingData.json.updateValue(downloadUrl, forKey: "jsonUrl")
                self.delegate?.downloadEnded!(with: .jsonSuccess, nil)
                
                self.storeRealTimeDB(withId: self.recordingId, info: self.recordingData.json, completion: { (error) in
                    //Handle Error
                    self.delegate?.downloadEnded!(with: .realtimeSuccess, error)
                })
                
                break
            }
            
        }
        
    }
    
    func stopUpload(withType type: UploadType, snapshot: FIRStorageTaskSnapshot){
        
        if let error = snapshot.error {
            self.delegate?.uploadEnded!(with: .error, error)
        }
    }
    
    func pauseUpload(withType type: UploadType, snapshot: FIRStorageTaskSnapshot) {
        //TODO: Implement Pause
    }
    
    func resumeUpload(withType type: UploadType, snapshot: FIRStorageTaskSnapshot){
        //TODO: Implement Resume
    }
    
    
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
