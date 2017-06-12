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
import AudioKit
import Synchronized

public protocol AudioManagerDelegate: NSObjectProtocol {
    func recievedRecordings()
    func emptyRecordingQueue()
    func playback(tape: Tape)
    func playbackError(error: Error?)
}

public class AudioManager: NSObject {//TODO: REDO EVERYTHING
    
    weak var delegate : AudioManagerDelegate?
    
    static var playbackQueue = AudioQueue<String>()
    
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
        guard let tapeId = AudioManager.playbackQueue.dequeue() else {
            delegate?.emptyRecordingQueue()
            return false
        }
        synchronized(object: self) { 
            if AudioManager.playbackQueue.isEmpty {
                delegate?.emptyRecordingQueue()
            }
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
            
            print("Recording at \(audioLocation.coordinate.latitude),\(audioLocation.coordinate.longitude)")
            
            if !AudioManager.playbackHistory.contains(audioId) {
                AudioManager.playbackQueue.enqueue(audioId)
                self.delegate?.recievedRecordings()
            }
        }
        
        query.observeReady { 
            //Query Finished
            //TODO: Increase Radius size if there is not enough Recordings in the Queue
            
            synchronized(object: self, closure: {
                if AudioManager.playbackQueue.underMin {
                    query.radius = SearchRadius.increase(radius: query.radius)
                    print("Increaing Radius")
                }
            })
            
        }
    }
    
    class func makeAudiofile(url : URL?) throws -> AKAudioFile {
        guard let tapeUrl = url else {
            throw AudioError.noTapeSet // Throw Error for not having the tape download url
        }
        do {
            let audioFile = try AKAudioFile(forReading: tapeUrl)
            return audioFile
        } catch {
            throw error
        }
        
    }
}
