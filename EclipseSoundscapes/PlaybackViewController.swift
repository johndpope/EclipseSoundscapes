////
////  PlaybackViewController.swift
////  EclipseSoundscapes
////
////  Created by Arlindo Goncalves on 6/13/17.
////
////  Copyright © 2017 Arlindo Goncalves.
////  This program is free software: you can redistribute it and/or modify
////  it under the terms of the GNU General Public License as published by
////  the Free Software Foundation, either version 3 of the License, or
////  (at your option) any later version.
////
////  This program is distributed in the hope that it will be useful,
////  but WITHOUT ANY WARRANTY; without even the implied warranty of
////  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
////  GNU General Public License for more details.
////
////  You should have received a copy of the GNU General Public License
////  along with this program.  If not, see [http://www.gnu.org/licenses/].
////
////  For Contact email: arlindo@eclipsesoundscapes.org
//
//import UIKit
//import CoreLocation
//import FirebaseStorage
//
//class PlaybackViewController: UIViewController {
//    
//    @IBOutlet weak var soundscapesImageView: UIImageView!
//    @IBOutlet weak var mediaControls: UIView!
//    @IBOutlet weak var startBtn: UIButton!
//    @IBOutlet weak var totalTimeLabel: UILabel!
//    
//    @IBOutlet weak var progressBar: UIProgressView!
//    
//    @IBOutlet weak var currentTimeLabel: UILabel!
//    
//    @IBOutlet weak var acitivtyMonitor: UIActivityIndicatorView!
//    @IBOutlet weak var stopBtn: UIButton!
//    @IBOutlet weak var skipBtn: UIButton!
//    @IBOutlet weak var playBtn: UIButton!
//    
//    let locator = Location()
//    let audioManager = AudioManager()
//    
//    var downloadTask : StorageDownloadTask?
//    
//    var player : TapePlayer?
//    
//    enum State {
//        case idle, playing, paused, downloading, downloadingPaused
//    }
//    
//    var state = State.idle {
//        didSet {
//            self.updateUI()
//        }
//    }
//    
//    var totalDuration : Double = 0 {
//        didSet {
//            self.endDuration = totalDuration
//        }
//    }
//    
//    var endDuration : Double = 0 {
//        didSet {
//            self.totalTimeLabel.text = "-\(Utility.timeString(time: endDuration))"
//        }
//    }
//    
//    var progress : Double = 0 {
//        didSet {
//            self.currentTimeLabel.text = Utility.timeString(time: progress)
//            self.endDuration -= 1
//        }
//    }
//    
//    var didRequestRecording = false
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Do any additional setup after loading the view.
//        locator.delegate = self
//        audioManager.delegate = self
//        
//        stopBtn.setImage(#imageLiteral(resourceName: "stop").withRenderingMode(.alwaysTemplate), for: .normal)
//        playBtn.setImage(#imageLiteral(resourceName: "play").withRenderingMode(.alwaysTemplate), for: .normal)
//        skipBtn.setImage(#imageLiteral(resourceName: "skip").withRenderingMode(.alwaysTemplate), for: .normal)
//        
//        startBtn.layer.cornerRadius = 5
//        
//        setText()
//        updateUI()
//    }
//    
//    func setText() {
//        self.startBtn.setTitle("Listen Now".localized().appending("!!"), for: .normal)
//    }
//    
//    @IBAction func play(_ sender: Any) {
//        if self.state == .downloadingPaused {
//            downloadTask?.resume()
//            
//        } else if self.state == .downloading {
//            downloadTask?.pause()
//            
//        } else if self.state == .playing {
//            self.state = .paused
//            self.player?.pause()
//            
//        } else {
//            self.state = .playing
//            self.player?.resume()
//        }
//    }
//    
//    @IBAction func stop(_ sender: Any) {
//        if self.state == .downloading || self.state == .downloadingPaused {
//            locator.stopLocating()
//            downloadTask?.cancel()
//            
//        } else {
//            self.player?.stop(.cancel)
//            player = nil
//        }
//        self.state = .idle
//    }
//    
//    @IBAction func next(_ sender: Any) {
//        if self.state == .playing || self.state == .paused {
//            self.player?.stop(.skip)
//            player = nil
//        }
//        getNextRecording()
//    }
//    
//    func getNextRecording() {
//        didRequestRecording = true
//        if !self.audioManager.nextTape() {
//            
//            guard let latitude = UserDefaults.standard.object(forKey: "Latitude") as? Double,
//                  let longitude = UserDefaults.standard.object(forKey: "Longitutde") as? Double else {
//                self.locator.getLocation(withAccuracy: kCLLocationAccuracyThreeKilometers)
//                return
//            }
//            print(latitude, longitude)
//            
////            audioManager.getTapedBasedOn(location: CLLocation(latitude: latitude, longitude: longitude))
//            self.state = .downloading
//        }
//        
//    }
//    
//    func playRecording(tape: Tape) {
//        self.player = TapePlayer(tape: tape)
//        self.player?.delegate = self
//        do {
//            try player?.play()
//            totalDuration = tape.duration ?? 1.0
//            self.state = .playing
//            
//        } catch {
//            print("Error tring to play: \(error.localizedDescription)")
//        }
//    }
//    
//    fileprivate func updateUI() {
//        switch self.state {
//        case .idle:
//            soundscapesImageView.isHidden = true
//            totalTimeLabel.isHidden = true
//            currentTimeLabel.isHidden = true
//            acitivtyMonitor.isHidden = true
//            self.progressBar.setProgress(0.0, animated: false)
//            UIView.animate(withDuration: 1.0, animations: {
//                self.mediaControls.isHidden = true
//                self.startBtn.isHidden = false
//            })
//            break
//            
//        case .downloading:
//            self.acitivtyMonitor.isHidden = false
//            self.acitivtyMonitor.startAnimating()
//            
//            self.playPauseBtn(isPlaying: true)
//            totalTimeLabel.isHidden = true
//            currentTimeLabel.isHidden = true
//            self.skipBtn.isEnabled = false
//            self.skipBtn.tintColor = .lightGray
//            UIView.animate(withDuration: 1.0, animations: {
//                self.mediaControls.isHidden = false
//                self.startBtn.isHidden = true
//            })
//            break
//            
//        case .downloadingPaused:
//            self.acitivtyMonitor.isHidden = true
//            self.acitivtyMonitor.stopAnimating()
//            
//            self.playPauseBtn(isPlaying: false)
//            break
//            
//        case .playing:
//            soundscapesImageView.isHidden = false
//            self.acitivtyMonitor.isHidden = true
//            self.acitivtyMonitor.stopAnimating()
//            
//            totalTimeLabel.isHidden = false
//            currentTimeLabel.isHidden = false
//            self.playPauseBtn(isPlaying: true)
//            self.skipBtn.isEnabled = true
//            self.skipBtn.tintColor = .white
//            break
//            
//        case .paused:
//            
//            self.playPauseBtn(isPlaying: false)
//            
//            break
//        }
//    }
//    
//    func playPauseBtn(isPlaying : Bool) {
//        if isPlaying {
//            self.playBtn.setImage(#imageLiteral(resourceName: "pause").withRenderingMode(.alwaysTemplate), for: .normal)
//        } else {
//            self.playBtn.setImage(#imageLiteral(resourceName: "play").withRenderingMode(.alwaysTemplate), for: .normal)
//        }
//        
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
//}
//extension PlaybackViewController : PlayerDelegate {
//    func progress(_ progress: Double) {
//        self.progress = progress
//        self.progressBar.setProgress(Float(progress/totalDuration), animated: true)
//    }
//    func finished() {
//        print("Player Finished")
//        getNextRecording()
//    }
//    func paused() {
//        print("Player Paused")
//    }
//    func resumed() {
//        print("Player Resumed")
//    }
//}
//
//extension PlaybackViewController : LocationDelegate {
//    
//    func presentFailureAlert(_ alert : UIViewController) {
//        self.state = .idle
//        self.present(alert, animated: true, completion: nil)
//    }
//    
//    func locator(didUpdateBestLocation location: CLLocation) {
////        self.audioManager.getTapedBasedOn(location: location)
//    }
//    
//    func locator(didFailWithError error: Error) {
//        print(error.localizedDescription)
//    }
//}
//extension PlaybackViewController : AudioManagerDelegate {
//    
//    func playbackError(error: Error?) {
//        print("Audio Playback Error \(error?.localizedDescription ?? "")")
//        self.state = .idle
//    }
//    
//    func playback(tape: Tape) {
//        playRecording(tape: tape)
//    }
//    
//    func recievedRecordings() {
//        if didRequestRecording {
//            self.next(self)
//            didRequestRecording = false
//        }
//    }
//    
//    func emptyRecordingQueue() {
//        print("No Recording in Queue =(")
//        self.state = .idle
//        //TODO: Handle Error to user staing that there is no recordings in their current radius
//    }
//    
//    func downloading() {
//        self.state = .downloading
//    }
//    
//    func stopDownloading() {
//        self.state = .downloadingPaused
//    }
//}
