//
//  RecordingViewController.swift
//  EclipseSoundscapes
//
//  Created by Anonymous on 6/12/17.
//  Copyright © 2017 DevByArlindo. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseStorage

class RecordingViewController: UIViewController {
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var recordBtn: UIButton!
    
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var pauseBtn: UIButton!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    var locator : Locator!
    
    var uploadTask : StorageUploadTask?
    
    enum RecordingState {
        case idle, recording, uploading, uploadingPaused
    }
    
    var state = RecordingState.idle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        locator = Locator()
        locator.delegate = self
        
        stopBtn.setImage(#imageLiteral(resourceName: "stop").withRenderingMode(.alwaysTemplate), for: .normal)
        playBtn.setImage(#imageLiteral(resourceName: "play").withRenderingMode(.alwaysTemplate), for: .normal)
        pauseBtn.setImage(#imageLiteral(resourceName: "pause").withRenderingMode(.alwaysTemplate), for: .normal)
        
        stopBtn.tintColor = .white
        playBtn.tintColor = .white
        pauseBtn.tintColor = .white
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pause(_ sender: Any) {
        if state == .uploading {
            self.uploadTask?.pause()
            self.state = .uploadingPaused
            updateUI()
        } else {
            self.recorder?.pause()
        }
    }
    @IBAction func play(_ sender: Any) {
        if state == .uploadingPaused {
            self.uploadTask?.resume()
            self.state = .uploading
            updateUI()
        } else {
            self.recorder?.resume()
        }
        
    }
    @IBAction func stop(_ sender: Any) {
        if state == .uploadingPaused || state == .uploading {
            self.uploadTask?.cancel()
        } else {
            self.recorder?.stop(.cancel, error: nil)
        }
    }
    
    @IBAction func start(_ sender: Any) {
        self.locator.getLocation(withAccuracy: kCLLocationAccuracyThreeKilometers)
        self.state = .recording
        updateUI()
    }
    
    var recorder : TapeRecorder?
    
    func record(atLocation location: CLLocation) {
        recorder = TapeRecorder(location: location)
        recorder?.delegate = self
        
        recorder?.requestPermission(handler: { (granted, alert) in
            DispatchQueue.main.async {
                if granted {
                    self.startRecording()
                } else {
                    self.present(alert!, animated: true, completion: nil)
                }
            }
        })
    }
    
    private func startRecording() {
        do {
            try self.recorder?.start()
        } catch {
            print(error)
        }
    }
    
    var uploader : Uploader!
    
    func uploadAudio(recording: Recording) {
        uploader = Uploader(recording: recording)
        uploadTask = uploader.storeAudio()
        
        self.progressBar.setProgress(0.0, animated: true)
        
        uploadTask?.observe(.progress, handler: { (snapshot) in
            let progress = Float(snapshot.progress!.completedUnitCount)/Float(snapshot.progress!.totalUnitCount)
            print("Audio Data progress: \(progress) ")
            self.progressBar.setProgress(progress, animated: true)
        })
        uploadTask?.observe(.failure, handler: { (snapshot) in
            print("Audio Data error: \(snapshot.error?.localizedDescription ?? "Error")")
        })
        uploadTask?.observe(.success, handler: { (_) in
            self.uploadInfo()
        })
        
    }
    
    func uploadInfo() {
        uploadTask = uploader.storeInformation()
        
        self.progressBar.setProgress(0.0, animated: true)
        
        uploadTask?.observe(.progress, handler: { (snapshot) in
            let progress = Float(snapshot.progress!.completedUnitCount)/Float(snapshot.progress!.totalUnitCount)
            print("Audio Info progress: \(progress)")
            self.progressBar.setProgress(progress, animated: true)
        })
        uploadTask?.observe(.failure, handler: { (snapshot) in
            print("Audio Info error: \(snapshot.error?.localizedDescription ?? "Error")")
        })
        uploadTask?.observe(.success, handler: { (_) in
            self.uploadLocationRef()
        })
        
    }
    
    func uploadLocationRef() {
        uploader.storeLocation { (lerror) in
            if let error = lerror {
                print("Location Ref error: \(error.localizedDescription)")
            }
            print("Upload Complete")
            
            DispatchQueue.main.async {
                self.state = .idle
                self.updateUI()
            }
            
        }
    }
    
    func updateUI() {
        switch self.state {
        case .idle:
            self.recordBtn.isEnabled = true
            self.recordBtn.tintColor = .blue
            
            self.playBtn.isEnabled = false
            self.playBtn.tintColor = .lightGray
            
            self.pauseBtn.isEnabled = false
            self.pauseBtn.tintColor = .lightGray
            
            self.progressBar.setProgress(0.0, animated: true)
            
            break
        case .recording:
            self.recordBtn.isEnabled = false
            self.recordBtn.tintColor = .lightGray
            
            self.playBtn.isEnabled = true
            self.playBtn.tintColor = .white
            
            self.pauseBtn.isEnabled = true
            self.pauseBtn.tintColor = .white
            
            break
        case .uploading:
            self.recordBtn.isEnabled = false
            self.recordBtn.tintColor = .lightGray
            
            self.playBtn.isEnabled = false
            self.playBtn.tintColor = .lightGray
            
        case .uploadingPaused:
            self.recordBtn.isEnabled = false
            self.recordBtn.tintColor = .lightGray
            
            self.pauseBtn.isEnabled = false
            self.pauseBtn.tintColor = .lightGray
            
            break
        }
    }
}

extension RecordingViewController : RecordingDelegate {
    func progress(_ progress: Double) {
        print("Progress")
        self.durationLabel.text = Utility.timeString(time: progress)
        self.progressBar.setProgress(Float(progress/RecordingDurationMax), animated: true)
    }
    
    func failed(withError error : AudioError) {
        print("Failed \(error.localizedDescription)")
        self.state = .idle
        updateUI()
    }
    func finished(_ recording: Recording) {
        print("Finished!!")
        self.uploadAudio(recording: recording)
        
        self.state = .uploading
        self.updateUI()
    }
    func paused() {
        print("Puased!!")
    }
    func resumed() {
        print("Resumed!!")
    }
}
extension RecordingViewController : LocatorDelegate {
    
    func presentAlert(_ alert : UIViewController) {
        self.present(alert, animated: true, completion: nil)
    }
    
    func locator(didUpdateBestLocation location: CLLocation) {
        record(atLocation: location)
        
    }
    
    func locator(didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
