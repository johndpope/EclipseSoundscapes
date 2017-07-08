//
//  ResourceManager.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 5/23/17.
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
import CoreData
import CoreLocation

/// Handles All Integration with local storage and CoreData entities
public class ResourceManager {
    
    /// Simple Wrappper for a ([Recording]?) -> Void Completion block
    typealias RecordingFetchCallback = (([Recording]?) -> Void)
    
    /// Simple Wrappper for a (Error?)->Void Completion block
    typealias RecordingModifyCallback = ((Error?) -> Void)
    
    /// Intance of NSManagedObjectContext
    var managedObjectContext : NSManagedObjectContext!
    
    /// Access to the ResourceManager Object
    static var manager = ResourceManager()
    
    /// Load Coredata on Device
    func loadCoreData() {
        guard let modelURL = Bundle.main.url(forResource: "Recordings", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = psc
        DispatchQueue.global(qos: .background).async {
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let docURL = urls[urls.endIndex-1]
            let storeURL = docURL.appendingPathComponent("Recording.sqlite")
            do {
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
            } catch {
                fatalError("Error migrating store: \(error)")
            }
            
        }
    }
    
    //TODO: Implement Passing the Recording through the notification for any subscribers
    func subscribeRecordingAdded(observer: Any, action: Selector, object: Any? = nil) {
        NotificationCenter.default.addObserver(observer, selector: action, name: NSNotification.Name.RecordingAdded, object: object)
        
    }
    
    //TODO: Implement Passing the Recording's key through the notification for any subscribers.
    // Cannot pass Recroding because notification occurs after deletion of the recoring form CoreData
    func subscribeRecordingDeleted(observer: Any, action: Selector, object: Any? = nil) {
        NotificationCenter.default.addObserver(observer, selector: action, name: NSNotification.Name.RecordingDeleted, object: object)
        
    }
    
    //TODO: Implement Passing the Recording through the notification for any subscribers.... Or Just use this as a refresh signal
    func subscribeRecordingChanged(observer: Any, action: Selector, object: Any? = nil) {
        NotificationCenter.default.addObserver(observer, selector: action, name: NSNotification.Name.RecordingChanged, object: object)
        
    }
    
    func unsubscribe(observer: Any, NotificationName name: Notification.Name, object: Any? = nil) {
        NotificationCenter.default.removeObserver(observer, name: name, object: object)
    }
    
    /// Save Managed Objects in Core Data aka Recordings
    func save() {
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failed trying to save context: \(error)")
        }
    }
    
    /// Fetch the Recordings in Core Data
    ///
    /// - Parameter completion: Completion Handler for fetched recordings
    /// - Throws: Error while trying to fetch Recordings
    func fetchRecordings(_ completion : RecordingFetchCallback) throws {
        
        do {
            let fetchedRecording : [Recording]?
            if #available(iOS 10.0, *) {
                fetchedRecording = try managedObjectContext.fetch(Recording.fetchRequest()) as? [Recording]
            } else {
                // Fallback on earlier versions
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Recording")
                fetchedRecording = try managedObjectContext.fetch(fetchRequest) as? [Recording]
            }
            completion(fetchedRecording)
            
        } catch {
            print("Failed to fetch Records: \(error)")
            throw error
            
        }
    }
    
    /// Create a new Recording
    ///
    /// - Returns: Newly created Recording
    func createRecording() -> Recording {
        let recording = NSEntityDescription.insertNewObject(forEntityName: "Recording", into: managedObjectContext) as! Recording
        recording.timestamp = NSDate()
        recording.id = UUID.init().uuidString
        return recording
    }
    
    /// Modify Recording's Title
    ///
    /// - Parameters:
    ///   - recording: Recording to modify
    ///   - title: Desired Recording Title
    ///   - shouldSave: Specify if modification should be saved in CoreData
    func setTitle(recording : Recording, title: String?, shouldSave: Bool = true) {
        recording.title = title
        if shouldSave {
            self.save()
            
            NotificationCenter.default.post(name: Notification.Name.RecordingChanged, object: nil)
        }
    }
    
    /// Modify Recording's Duration
    ///
    /// - Parameters:
    ///   - recording: Recording to modify
    ///   - duration: Duration of Recoding
    ///   - shouldSave: Specify if modification should be saved in CoreData
    func setDuration(recording: Recording, duration: TimeInterval, shouldSave: Bool = true) {
        recording.duration = duration
        if shouldSave {
            self.save()
            NotificationCenter.default.post(name: Notification.Name.RecordingChanged, object: nil)
        }
    }
    
    /// Modify Recording's Location
    ///
    /// - Parameters:
    ///   - recording: Recording to modify
    ///   - location: Structure Containg Recording Latitude and Longitude
    ///   - shouldSave: Specify if modification should be saved in CoreData
    func setLocation(recording: Recording, location: CLLocationCoordinate2D, shouldSave: Bool = true) {
        recording.latitude = location.latitude
        recording.longitude = location.longitude
        
        if shouldSave {
            self.save()
            NotificationCenter.default.post(name: Notification.Name.RecordingChanged, object: nil)
        }
    }
    
    /// Insert a completed recording with audio and inforamtion to Core Data
    ///
    /// - Parameters:
    ///   - recording: Recording
    ///   - info: Inforamtion about the Recording
    ///         - size
    ///         - duration
    ///         - title
    ///         - location
    func instertRecording(recording: Recording, info: Dictionary<String, Any>) {
        if let duration = info[Recording.DURATION] as? TimeInterval {
            setDuration(recording: recording, duration: duration, shouldSave: false)
        }
        
        if let title = info[Recording.TITLE] as? String {
            setTitle(recording: recording, title: title, shouldSave: false)
        }
        
        if let location = info[Recording.LOCATION]as? CLLocationCoordinate2D {
            setLocation(recording: recording, location: location, shouldSave: false)
        }
        
        self.save()
        
        NotificationCenter.default.post(name: Notification.Name.RecordingAdded, object: nil)
    }
    
    /// Delete the given Recording
    ///
    /// - Parameters:
    ///   - recording: Recording
    ///   - completion: optional Completion block that containing a possible error
    ///     - Error would involve no Recording Data at the URL of the Recording
    func deleteRecording(recording : Recording, completion: ((Error?) -> Void)? = nil) {
        do {
            
            managedObjectContext.delete(recording)
            self.save()
            NotificationCenter.default.post(name: Notification.Name.RecordingDeleted, object: nil)
            if let url = ResourceManager.recordingURL(id: recording.id!) as URL? {
                try FileManager.default.removeItem(at: url)
            }
            completion?(nil)
            print("File Deleted")
        } catch {
            print("File Not Deleted: \(error)")
            completion?(error)
        }
    }
    
    /// Build Inforamtion Structure for the Recording to get ready for upload
    ///
    /// - Parameter:
    ///     - recording: Recording
    ///     - degub: Print the output of the created JSON
    /// - Returns: Data
    static func recordingInfo(recording: Recording, debug: Bool = false) -> Data? {
        
        var json = Dictionary<String, Any>()
        json.updateValue(recording.id ?? "", forKey: Recording.ID)
        json.updateValue(recording.title ?? "", forKey: Recording.TITLE)
        json.updateValue(prettyDate(date: recording.timestamp as Date?), forKey: Recording.TIMESTAMP)
        json.updateValue(recording.latitude, forKey: Recording.LAT)
        json.updateValue(recording.longitude, forKey: Recording.LONG)
        json.updateValue(recording.duration, forKey: Recording.DURATION)
        json.updateValue(recording.info ?? "", forKey: Recording.INFO)
        
        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            if debug {
                let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
                print("json string = \(jsonString)")
            }
            
            return jsonData
            
        } catch _ {
            print ("JSON Failure")
            return nil
        }
        
    }
    
    static func buildInfoFromData(withData data: Data?) -> Dictionary<String, Any>? {
        guard let jsonData = data else {
            return nil
        }
        
        do {
            let jsonObj = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! Dictionary<String, Any>
            
            return jsonObj
        } catch {
            print ("JSON Conversion Failure")
            return nil
        }
    }
    
    /// Get the Size of the file at the given path
    ///
    /// - Parameter path: Path to File
    /// - Returns: Byte representation of the File Size
    static func getFileSize(path:String) -> UInt64 {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: path)
            if let fileSize = fileAttributes[FileAttributeKey.size] {
                return (fileSize as! NSNumber).uint64Value
            } else {
                print("Failed to get a size attribute from path: \(path)")
            }
        } catch {
            print("Failed to get file attributes for local path: \(path) with error: \(error.localizedDescription)")
        }
        return 0
    }
    
    /// Utitly Method to return the Documents Directory URL
    ///
    /// - Returns: Documents Directory URL
    static func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    /// Utitly Method to return the Recording's URL
    ///
    /// - Parameter id: Recording's id
    /// - Returns: Recording URL
    static func recordingURL(id : String) -> URL {
        return getDocumentsDirectory().appendingPathComponent(id.appending(FileType))
    }
    
    /// Delete a File at path
    ///
    /// - Parameter path: Path to file
    static func deleteFile(atPath path: URL?) {
        guard let url = path else {
            print("Path is nil")
            return
        }
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Download File delete Error: \(error.localizedDescription)")
        }
    }
    
    /// Utitlty to Convert a Date to a User Friendly String
    ///
    /// - Parameter date: Date
    /// - Returns: Pretty String of the Date
    static func prettyDate(date: Date?) -> String {
        guard date != nil else {
            return ""
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        
        return formatter.string(from: date!)
    }
}

extension Recording {
    static let LOCATION = "location"
    static let DURATION = "duration"
    static let TITLE = "title"
    static let PATH = "path"
    static let TIMESTAMP = "timestamp"
    static let ID = "id"
    static let LAT = "latitude"
    static let LONG = "longitude"
    static let INFO = "info"
}

extension Notification.Name {
    static let RecordingAdded = Notification.Name.init(rawValue: "RecordingAdded")
    static let RecordingDeleted = Notification.Name.init(rawValue: "RecordingDeleted")
    static let RecordingChanged = Notification.Name.init(rawValue: "RecordingChanged")
    
}
