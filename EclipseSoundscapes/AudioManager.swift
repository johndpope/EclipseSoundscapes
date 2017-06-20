//
//  AudioManager.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 6/7/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import GeoFire
import Synchronized

public protocol AudioManagerDelegate: NSObjectProtocol {
    func recievedRecordings()
    func emptyRecordingQueue()
    func playback(tape: Tape)
    func playbackError(error: Error?)
    func downloading()
    func stopDownloading()
}

public class AudioManager: NSObject {
    
    weak var delegate : AudioManagerDelegate?
    
    var playbackQueue = AudioQueue<String>()
    
    static var playbackHistory = Set<String>()
    
    private var database :Database!
    
    var queryHandle :UInt = 0
    
    let downloader = Downloader()
    
    var downloadTask : StorageDownloadTask?
    
    public override init() {
        super.init()
        database = Database.database()
    }
    
    func pause() {
        self.downloadTask?.pause()
    }
    
    func resume() {
        self.downloadTask?.resume()
    }
    
    func stop() {
        self.downloadTask?.cancel()
        downloader.delete()
    }
    
    func nextTape() -> Bool {
        guard let tapeId = playbackQueue.dequeue() else {
            return false
        }
        self.downloadRecording(recordingId: tapeId)
        return true
    }
    
    private func downloadRecording(recordingId : String) {
        
        downloadTask = downloader.downloadAudio(withId: recordingId) { (url, error) in
            guard error == nil, let audioUrl = url else {
                return
            }
            self.downloadInfo(recordingId: recordingId, audioUrl: audioUrl)
        }
        downloadTask?.observe(.progress, handler: { (snapshot) in
            // Failure
            print("Audio: \(snapshot.progress?.fractionCompleted ?? 0.0)")
        })
        
        downloadTask?.observe(.pause, handler: { (_) in
            self.delegate?.stopDownloading()
        })
        
        downloadTask?.observe(.resume, handler: { (_) in
            self.delegate?.downloading()
        })
        
        downloadTask?.observe(.failure, handler: { (snapshot) in
            // Failure
            self.delegate?.playbackError(error: snapshot.error)
            self.downloader.delete()
        })
    }
    
    private func downloadInfo (recordingId : String, audioUrl : URL) {
        downloadTask = downloader.downloadInforamtion(withId: recordingId) { (info, error) in
            guard error == nil, let audioInfo = info else {
                return
            }
            let tape = Tape(withInfo: audioInfo, audioUrl)
            
            self.delegate?.playback(tape: tape)
        }
        downloadTask?.observe(.failure, handler: { (snapshot) in
            // Failure
            self.delegate?.playbackError(error: snapshot.error)
            self.downloader.delete()
        })
        downloadTask?.observe(.progress, handler: { (snapshot) in
            // Failure
            print("Info: \(snapshot.progress?.fractionCompleted ?? 0.0)")
        })
        
        downloadTask?.observe(.pause, handler: { (_) in
            self.delegate?.stopDownloading()
        })
        
        downloadTask?.observe(.resume, handler: { (_) in
            self.delegate?.downloading()
        })
    }
    
    func getTapedBasedOn(location: CLLocation) {
        
        let locationRef = database.reference().child(LocationDirectory)
        
        guard let geoFire = GeoFire(firebaseRef: locationRef) else {
            return
        }
        
        guard let query = geoFire.query(at: location, withRadius: SearchRadius.radius(withSize: RadiusSize.fifty)) else {
            return
        }
        
        queryHandle = query.observe(.keyEntered) { (id, location) in
            
            guard let audioId = id, let audioLocation = location else {
                return
            }
            if !AudioManager.playbackHistory.contains(audioId) {
                print("Added Recording at \(audioLocation.coordinate.latitude),\(audioLocation.coordinate.longitude)")
                self.playbackQueue.enqueue(audioId)
                self.delegate?.recievedRecordings()
                AudioManager.playbackHistory.update(with: audioId)
            }
            
        }
        
        query.observeReady {
            //Query Finished
            //TODO: Increase Radius size if there is not enough Recordings in the Queue
            if self.playbackQueue.isEmpty {
                if SearchRadius.largerThanMax(radius: query.radius) {
                    self.delegate?.emptyRecordingQueue()
                    query.removeObserver(withFirebaseHandle: self.queryHandle)
                } else {
                    print("Increaing Radius")
                    query.radius = SearchRadius.increase(radius: query.radius)
                }
                
            } else {
                query.removeAllObservers()
            }
        }
    }
}
