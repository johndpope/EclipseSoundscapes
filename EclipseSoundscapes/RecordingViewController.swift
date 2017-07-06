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
    
    @IBOutlet weak var activityMonitor: UIActivityIndicatorView!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var mediaControls: UIView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var recordBtn: UIButton!

    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var locator : Location!
    
    var uploadTask : StorageUploadTask?
    
    enum State {
        case idle, locating, recording, recordingPaused, uploading, uploadingPaused
    }
    
    var state = State.idle {
        didSet {
            self.updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        locator = Location()
        locator.delegate = self
        
        recordBtn.layer.cornerRadius = recordBtn.frame.width/2
        cancelBtn.layer.cornerRadius = cancelBtn.frame.width/2
        
        startBtn.layer.cornerRadius = 5
        
        updateUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func stop(_ sender: Any) {
        if state == .uploadingPaused || state == .uploading {
            self.uploadTask?.cancel()
            
        } else if state == .locating {
            self.locator.stopLocating()
            
        } else {
            self.recorder?.stop(.cancel, error: nil)
        }
        self.state = .idle
    }
    @IBAction func record( _ sender : Any) {
        
        switch state {
        case .idle:
            self.locator.getLocation(withAccuracy: kCLLocationAccuracyThreeKilometers)
            self.state = .locating
            break
        case .recording:
            self.recorder?.pause()
            self.state = .recordingPaused
            break
        case .recordingPaused:
            self.recorder?.resume()
            self.state = .recording
            break
        case .uploading:
            self.uploadTask?.pause()
            self.state = .uploadingPaused
            break
        case.uploadingPaused:
            self.uploadTask?.resume()
            self.state = .uploading
            break
        default:
            break
        }
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
            try self.recorder?.record()
            self.state = .recording
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
//        uploader.storeLocation { (lerror) in
//            if let error = lerror {
//                print("Location Ref error: \(error.localizedDescription)")
//            }
//            print("Upload Complete")
//            
//            DispatchQueue.main.async {
//                self.state = .idle
//            }
//            
//        }
    }
    
    func updateUI() {
        switch self.state {
        case .idle:
            
            cancelBtn.isHidden = true
            mediaControls.isHidden = true
            startBtn.isHidden = false
            activityMonitor.isHidden = true
            activityMonitor.stopAnimating()
            break
        case .locating:
            startBtn.isHidden = true
            activityMonitor.startAnimating()
            activityMonitor.isHidden = false
            self.cancelBtn.isHidden = false
            break
        case .recording:
            
            mediaControls.isHidden = false
            recordBtn.backgroundColor = .red
            break
        case .recordingPaused:
            
            recordBtn.backgroundColor = .white
            break
        case .uploading:
            
            recordBtn.backgroundColor = UIColor.init(red: 219/255, green: 93/255, blue: 18/255, alpha: 1.0)
            break
        case .uploadingPaused:
            
            recordBtn.backgroundColor = .white
            break
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
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
    }
    func finished(_ recording: Recording) {
        print("Finished!!")
        self.uploadAudio(recording: recording)
        
        self.state = .uploading
    }
    func paused() {
        print("Puased!!")
    }
    func resumed() {
        print("Resumed!!")
    }
}
extension RecordingViewController : LocationDelegate {
    
    func presentFailureAlert(_ alert : UIViewController) {
        activityMonitor.stopAnimating()
        activityMonitor.isHidden = true
        self.present(alert, animated: true, completion: nil)
    }
    
    func locator(didUpdateBestLocation location: CLLocation) {
        activityMonitor.stopAnimating()
        activityMonitor.isHidden = true
        record(atLocation: location)
    }
    
    func locator(didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
