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


@objc public protocol AudioManagerDelegate: NSObjectProtocol {
    func recievedRecordings()
    func emptyRecordingQueue()
    @objc optional func presentAlert(_ alert : UIViewController)
    @objc optional func failedLocationRequest(error: Error)
}

public class AudioManager: NSObject {
    
    
    
    var locator = Locator()
    
    weak var delegate : AudioManagerDelegate?
    
    static var playbackQueue = AudioQueue<String>()
    
    static var playbackHistory = Set<String>()
    
    private var database = Database.database()
    
    var queryHandle : UInt = 0

    func next() -> String? {
        guard let tapeId = AudioManager.playbackQueue.dequeue() else {
            delegate?.emptyRecordingQueue()
            return nil
        }
        if AudioManager.playbackQueue.count == 0 {
            delegate?.emptyRecordingQueue()
        }
        
        return tapeId
    }
    
    func prepareGetTapes() {
        locator.delegate = self
        locator.getLocation()
    }
    
    func getTapedBasedOn(location: CLLocation){
        let locatonStatus = Locator.LocationAuthorization
        
        if locatonStatus != .authorizedAlways && locatonStatus != .authorizedWhenInUse {
            delegate?.failedLocationRequest?(error: AudioError.locationPermissionError)
            return
        }
        
        let locationRef = database.reference().child(LocationDirectory)
        
        guard let geoFire = GeoFire(firebaseRef: locationRef) else {
            return
        }
        
        guard let query = geoFire.query(at: location, withRadius: Radius/1000) else {
            return
        }
        
        query.observeReady { 
            //TODO: Change UI for Through delegate method when the Data is Ready
        }
        
        queryHandle = query.observe(.keyEntered) { (id, audioLocation) in
            if let audioId = id {
                if AudioManager.playbackQueue.enqueue(audioId){
                    self.delegate?.recievedRecordings()
                }
                
                
            }
            
        }
        
    }
    
    
    
    
}
extension AudioManager : LocatorDelegate {
    
    public func presentAlert(_ alert : UIViewController){
        if let window = UIApplication.shared.keyWindow {
            if let root = window.rootViewController{
                root.present(alert, animated: true, completion: nil)
            }
        }
        delegate?.presentAlert?(alert)
    }
    
    public func locator(didUpdateBestLocation location: CLLocation){
        getTapedBasedOn(location: location)
    }
    
    
    public func locator(didFailWithError error: Error){
        delegate?.failedLocationRequest?(error: error)
    }
}
