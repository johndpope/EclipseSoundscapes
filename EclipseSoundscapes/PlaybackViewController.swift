//
//  PlaybackViewController.swift
//  EclipseSoundscapes
//
//  Created by Arlindo Goncalves on 6/13/17.
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

import UIKit

class PlaybackViewController: UIViewController {
    
    var event: Event? {
        didSet {
            self.soundscapesImageView.image = event?.image
            self.captionsTextView.attributedText = event?.description
        }
    }
    
    var closedCaptionOn = false {
        didSet {
            soundscapesImageView.isHidden = closedCaptionOn
            captionsTextView.isHidden = !closedCaptionOn
        }
    }
    
    @IBOutlet weak var captionsTextView: UITextView!
    @IBOutlet weak var soundscapesImageView: UIImageView!
    @IBOutlet weak var mediaControls: UIView!
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var closedCaptionBtn: UIButton!
    
    let locator = Location()
    let audioManager = AudioManager()
    
    var player : TapePlayer?
    
    enum State {
        case idle, playing, paused
    }
    
    var state = State.idle {
        didSet {
            self.updateUI()
        }
    }
    
    var totalDuration : Double = 0 {
        didSet {
            self.endDuration = totalDuration
        }
    }
    
    var endDuration : Double = 0 {
        didSet {
            self.totalTimeLabel.text = "-\(Utility.timeString(time: endDuration))"
        }
    }
    
    var progress : Double = 0 {
        didSet {
            self.currentTimeLabel.text = Utility.timeString(time: progress)
            self.endDuration -= 1
        }
    }
    
    var didRequestRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        playBtn.setImage(#imageLiteral(resourceName: "play").withRenderingMode(.alwaysTemplate), for: .normal)
        closeBtn.setImage(#imageLiteral(resourceName: "cancel").withRenderingMode(.alwaysTemplate), for: .normal)

        updateUI()
    }
    
    @IBAction func play(_ sender: Any) {
        if self.state == .playing {
            self.state = .paused
            self.player?.pause()
            
        } else {
            self.state = .playing
            self.player?.resume()
        }
    }
    
    func playRecording(tape: Tape) {
        self.player = TapePlayer(tape: tape)
        self.player?.delegate = self
        do {
            try player?.play()
            totalDuration = tape.duration ?? 1.0
            self.state = .playing
            
        } catch {
            print("Error tring to play: \(error.localizedDescription)")
        }
    }
    
    fileprivate func updateUI() {
        switch self.state {
        case .idle:
            break
        case .playing:
            self.playPauseBtn(isPlaying: true)
            break
        case .paused:
            self.playPauseBtn(isPlaying: false)
            break
        }
    }
    
    func playPauseBtn(isPlaying : Bool) {
        if isPlaying {
            self.playBtn.setImage(#imageLiteral(resourceName: "pause").withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            self.playBtn.setImage(#imageLiteral(resourceName: "play").withRenderingMode(.alwaysTemplate), for: .normal)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func toggleCaptions(_ sender: Any) {
        closedCaptionOn = !closedCaptionOn
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
extension PlaybackViewController : PlayerDelegate {
    func progress(_ progress: Double) {
        self.progress = progress
        self.progressBar.setProgress(Float(progress/totalDuration), animated: true)
    }
    func finished() {
        print("Player Finished")
    }
    func paused() {
        print("Player Paused")
    }
    func resumed() {
        print("Player Resumed")
    }
}
