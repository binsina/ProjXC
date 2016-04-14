//
//  RecordMessageViewController.swift
//  Masjid Afghani
//
//  Created by Applied Sciences on 3/28/16.
//  Copyright © 2016 wahid hossaini. All rights reserved.
//

import AVFoundation
import UIKit

class RecordMessageViewController: UIViewController, AVAudioRecorderDelegate {
    var stackView: UIStackView!
    
    var recordButton: UIButton!
    var playButton: UIButton!
    
    var recordingSession: AVAudioSession!
    var messageRecorder: AVAudioRecorder!
    var messagePlayer: AVAudioPlayer!
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = UIColor.grayColor()
        
        stackView = UIStackView()
        stackView.spacing = 30
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = UIStackViewDistribution.FillEqually
        stackView.alignment = UIStackViewAlignment.Center
        stackView.axis = .Vertical
        view.addSubview(stackView)
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[stackView]|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: ["stackView": stackView]))
        view.addConstraint(NSLayoutConstraint(item: stackView, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant:0))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Record your Notice"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Record", style: .Plain, target: nil, action: nil)
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        self.loadFailUI()
                    }
                }
            }
        } catch {
            self.loadFailUI()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func loadRecordingUI() {
        recordButton = UIButton()
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.setTitle("Press to Record", forState: .Normal)
        recordButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle1)
        recordButton.addTarget(self, action: #selector(RecordMessageViewController.recordTapped), forControlEvents: .TouchUpInside)
        stackView.addArrangedSubview(recordButton)
        
        playButton = UIButton()
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.setTitle("Press to Play", forState: .Normal)
        playButton.hidden = true
        playButton.alpha = 0
        playButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle1)
        playButton.addTarget(self, action: #selector(RecordMessageViewController.playTapped), forControlEvents: .TouchUpInside)
        stackView.addArrangedSubview(playButton)
    }
    
    func loadFailUI() {
        let failLabel = UILabel()
        failLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        failLabel.text = "Recording failed: please ensure the app has access to your microphone."
        failLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(failLabel)
    }
    
    class func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as [String]
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    class func getWhistleURL() -> NSURL {
        let audioFilename = getDocumentsDirectory().stringByAppendingPathComponent("message.m4a")
        let audioURL = NSURL(fileURLWithPath: audioFilename)
        
        return audioURL
    }
    
    func startRecording() {
        // 1
        view.backgroundColor = UIColor(red: 0.6, green: 0, blue: 0, alpha: 1)
        
        // 2
        recordButton.setTitle("Tap to Stop", forState: .Normal)
        
        // 3
        let audioURL = RecordMessageViewController.getWhistleURL()
        print(audioURL.absoluteString)
        
        // 4
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
        ]
        
        do {
            // 5
            messageRecorder = try AVAudioRecorder(URL: audioURL, settings: settings)
            messageRecorder.delegate = self
            messageRecorder.record()
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success success: Bool) {
        view.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
        
        messageRecorder.stop()
        messageRecorder = nil
        
        if success {
            recordButton.setTitle("Press here to Re-Record", forState: .Normal)
            
            if playButton.hidden {
                UIView.animateWithDuration(0.35) { [unowned self] in
                    self.playButton.hidden = false
                    self.playButton.alpha = 1
                }
            }
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: #selector(RecordMessageViewController.nextTapped))
        } else {
            recordButton.setTitle("Press Here to Record", forState: .Normal)
            
            let ac = UIAlertController(title: "Record failed", message: "There was a problem recording your message; please try again.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    
    func recordTapped() {
        if messageRecorder == nil {
            startRecording()
            
            if !playButton.hidden {
                UIView.animateWithDuration(0.35) { [unowned self] in
                    self.playButton.hidden = true
                    self.playButton.alpha = 0
                }
            }
        } else {
            finishRecording(success: true)
        }
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func playTapped() {
        let audioURL = RecordMessageViewController.getWhistleURL()
        
        do {
            messagePlayer = try AVAudioPlayer(contentsOfURL: audioURL)
            messagePlayer.play()
        } catch {
            let ac = UIAlertController(title: "Playback failed", message: "There was a problem playing your Notice; please try re-recording.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    
    func nextTapped() {
        let vc = SelectlanguageViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
