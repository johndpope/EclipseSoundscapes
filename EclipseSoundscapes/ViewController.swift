//
//  ViewController.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 6/1/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var startLabel: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    
    var isRecording = false 
    var isPaused = false
    
    var locationManager : Locator!
    var recorder : TapeRecorder!
    var task : RecordTapeTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        locationManager = Locator()
        locationManager.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func start(_ sender: Any) {
        if isRecording {
            if isPaused{
                task?.resume()
                isPaused = false
            }
            else {
                task?.pause()
                isPaused = true
            }
        }
        else {
            locationManager.getLocation()
        }
    }

    @IBAction func stop(_ sender: Any) {
        task?.stop(.stop)
        task = nil
    }
    
    
    
    func startRecording(_ location :CLLocation) {
        
        recorder = TapeRecorder(location: location)
        recorder.requestPermission { (granted) in
            if granted {
                self.begin()
            }
            else {
                print("Not Granted")
            }
        }
        
        
    }
    
    func begin(){
        do {
            task = try recorder.prepareRecording()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        
        isRecording = true
        
        task?.observe(.duration) { (piece) in
            self.startLabel.text = self.timeString(time: piece.duration)
        }
        task?.observe(.failure) { (piece) in
            self.isRecording = false
            if let error = piece.error {
                print("Error: \(error.localizedDescription)")
            }
        }
        task?.observe(.success) { (piece) in
            self.isRecording = false
            if let recording = piece.recording {
                print("Location: \(recording.latitude), \(recording.longitude)")
                self.uploadAudio(recording: recording)
            }
            
        }
    }
    
    /// Convert TimeInterval into a pretty string
    ///
    /// - Parameter time: TimeInterval
    /// - Returns: Pretty Time String
    func timeString(time:TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = time - Double(minutes) * 60
        return String(format:"%02i:%02i",minutes,Int(seconds))
    }
    
    
    
}

extension ViewController : LocatorDelegate {
    /// Present Alert due to lack of permission or error
    ///
    /// - Parameter alert: Alert
    func presentAlert(_ alert : UIViewController){
        self.present(alert, animated: true, completion: nil)
    }
    
    
    /// Update of user's lastest location
    ///
    /// - Parameter:
    ///   - location: Best last Location
    func locator(didUpdateBestLocation location: CLLocation){
        startRecording(location)
    }
    
    
    /// Update of user's lastest location failed
    ///
    /// - Parameter:
    ///   - error: Error trying to get user's last location
    func locator(didFailWithError error: Error){
        print("Error getting Location: \(error.localizedDescription)")
    }
}
