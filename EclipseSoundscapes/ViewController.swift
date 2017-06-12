//
//  ViewController.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 6/1/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    let locator = Locator()
    let audioManager = AudioManager()
    
    var player : TapePlayer?
    var session : TapePlaybackSession?
    
    var signedIn = false
    
    var askedForRecording = false
    
    enum DownloadState {
        case notBegun, audio, info
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        locator.delegate = self
        audioManager.delegate = self
    }
    
    @IBAction func pause(_ sender: Any) {
                self.session?.pause()
    }
    @IBAction func play(_ sender: Any) {
        
        self.session?.resume()
        
    }
    @IBAction func stop(_ sender: Any) {
        self.session?.stop(.cancel, error: nil)
    }
    
    @IBAction func next(_ sender: Any) {
        if signedIn {
            askedForRecording = true
            getRecording()
        }
        self.startBtn.isEnabled = false
        self.startBtn.backgroundColor = .lightGray
        
    }
    
    func getRecording() {
        if !self.audioManager.nextTape() {
            self.locator.getLocation(withAccuracy: kCLLocationAccuracyThreeKilometers)
        }
        
    }
    
    func playRecording(tape: Tape) {
        let duration = tape.duration ?? 1.0
        self.totalTimeLabel.text = Utility.timeString(time: duration)
        self.player = TapePlayer(tape: tape)
        do {
            session = try player?.play()
            session?.observe(.success, handler: { (_) in
                print("All Done!")
            })
            session?.observe(.failure, handler: { _ in
                print("Recoring Finished Playing")
            })
            session?.observe(.progress, handler: { (piece) in
                
                self.currentTimeLabel.text = Utility.timeString(time: piece.progress)
                self.totalTimeLabel.text = Utility.timeString(time: duration - piece.progress)
                
                self.progressBar.setProgress(Float(piece.progress/duration), animated: true)
                
            })
            
        } catch {
            print("Error tring to play: \(error.localizedDescription)")
        }
        
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension ViewController : LocatorDelegate {
    
    func presentAlert(_ alert : UIViewController) {
        self.present(alert, animated: true, completion: nil)
    }
    
    func locator(didUpdateBestLocation location: CLLocation) {
        self.audioManager.getTapedBasedOn(location: location)
    }
    
    func locator(didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
extension ViewController : AudioManagerDelegate {
    
    func playbackError(error: Error?) {
        print("Audio Playback Error \(error?.localizedDescription ?? "")")
    }
    
    func playback(tape: Tape) {
        playRecording(tape: tape)
    }
    
    func recievedRecordings() {
        print("Recordings in Queue!")
        if askedForRecording {
            getRecording()
            askedForRecording = false
        }
    }
    
    func emptyRecordingQueue() {
        print("No Recording in Queue =(")
    }
}
