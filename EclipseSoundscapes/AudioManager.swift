//
//  AudioManager.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 6/7/17.
//
//  Copyright © 2017 Arlindo Goncalves.
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see [http://www.gnu.org/licenses/].
//
//  For Contact email: arlindo@eclipsesoundscapes.org

import Foundation
import CoreLocation

//public protocol AudioManagerDelegate: NSObjectProtocol {
//    func recievedRecordings()
//    func emptyRecordingQueue()
//    func playback(tape: Tape)
//    func playbackError(error: Error?)
//    func downloading()
//    func stopDownloading()
//}

public class AudioManager: NSObject {
    
//    weak var delegate : AudioManagerDelegate?
//    
//    static var playbackHistory = Set<String>()
//    
//    private var database :Database!
//    
//    var queryHandle :UInt = 0
//    
//    let downloader = Downloader()
//    
//    var downloadTask : StorageDownloadTask?
//    
//    public override init() {
//        super.init()
//        database = Database.database()
//    }
//    
//    func pause() {
//        self.downloadTask?.pause()
//    }
//    
//    func resume() {
//        self.downloadTask?.resume()
//    }
//    
//    func stop() {
//        self.downloadTask?.cancel()
//        downloader.delete()
//    }
    
//    func nextTape() -> Bool {
//        guard let tapeId = playbackQueue.dequeue() else {
//            return false
//        }
//        self.downloadRecording(recordingId: tapeId)
//        return true
//    }
    
//    private func downloadRecording(recordingId : String) {
//        
//        downloadTask = downloader.downloadAudio(withId: recordingId) { (url, error) in
//            guard error == nil, let audioUrl = url else {
//                return
//            }
//            self.downloadInfo(recordingId: recordingId, audioUrl: audioUrl)
//        }
//        downloadTask?.observe(.progress, handler: { (snapshot) in
//            // Failure
//            print("Audio: \(snapshot.progress?.fractionCompleted ?? 0.0)")
//        })
//        
//        downloadTask?.observe(.pause, handler: { (_) in
//            self.delegate?.stopDownloading()
//        })
//        
//        downloadTask?.observe(.resume, handler: { (_) in
//            self.delegate?.downloading()
//        })
//        
//        downloadTask?.observe(.failure, handler: { (snapshot) in
//            // Failure
//            self.delegate?.playbackError(error: snapshot.error)
//            self.downloader.delete()
//        })
//    }
//    
//    private func downloadInfo (recordingId : String, audioUrl : URL) {
//        downloadTask = downloader.downloadInforamtion(withId: recordingId) { (info, error) in
//            guard error == nil, let audioInfo = info else {
//                return
//            }
//            let tape = Tape(withInfo: audioInfo, audioUrl)
//            
//            self.delegate?.playback(tape: tape)
//        }
//        downloadTask?.observe(.failure, handler: { (snapshot) in
//            // Failure
//            self.delegate?.playbackError(error: snapshot.error)
//            self.downloader.delete()
//        })
//        downloadTask?.observe(.progress, handler: { (snapshot) in
//            // Failure
//            print("Info: \(snapshot.progress?.fractionCompleted ?? 0.0)")
//        })
//        
//        downloadTask?.observe(.pause, handler: { (_) in
//            self.delegate?.stopDownloading()
//        })
//        
//        downloadTask?.observe(.resume, handler: { (_) in
//            self.delegate?.downloading()
//        })
//    }
    
//    func getTapedBasedOn(location: CLLocation) {
//        
//        let locationRef = database.reference().child(LocationDirectory)
//        
//        guard let geoFire = GeoFire(firebaseRef: locationRef) else {
//            return
//        }
//        
//        guard let query = geoFire.query(at: location, withRadius: SearchRadius.radius(withSize: RadiusSize.fifty)) else {
//            return
//        }
//        
//        queryHandle = query.observe(.keyEntered) { (id, location) in
//            
//            guard let audioId = id, let audioLocation = location else {
//                return
//            }
//            if !AudioManager.playbackHistory.contains(audioId) {
//                print("Added Recording at \(audioLocation.coordinate.latitude),\(audioLocation.coordinate.longitude)")
//                self.playbackQueue.enqueue(audioId)
//                self.delegate?.recievedRecordings()
//                AudioManager.playbackHistory.update(with: audioId)
//            }
//            
//        }
//        
//        query.observeReady {
//            //Query Finished
//            //TODO: Increase Radius size if there is not enough Recordings in the Queue
//            if self.playbackQueue.isEmpty {
//                if SearchRadius.largerThanMax(radius: query.radius) {
//                    self.delegate?.emptyRecordingQueue()
//                    query.removeObserver(withFirebaseHandle: self.queryHandle)
//                } else {
//                    print("Increaing Radius")
//                    query.radius = SearchRadius.increase(radius: query.radius)
//                }
//                
//            } else {
//                query.removeAllObservers()
//            }
//        }
//    }
    
    class func loadAudio(withName name: String, withExtension ext: FileType?) -> Tape? {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext?.rawValue) else {
            return nil
        }
        
        let tape = Tape(audioUrl: url)
        return tape
    }
}
