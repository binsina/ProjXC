//
//  SubmitView.swift
//  Masjid Afghani
//
//  Created by Applied Sciences on 3/28/16.
//  Copyright © 2016 wahid hossaini. All rights reserved.
//

import CloudKit
import UIKit


class SubmitViewController: UIViewController {
    var language: String!
    var comments: String!
    
    var stackView: UIStackView!
    var status: UILabel!
    var spinner: UIActivityIndicatorView!
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = UIColor.grayColor()
        
        stackView = UIStackView()
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = UIStackViewDistribution.FillEqually
        stackView.alignment = UIStackViewAlignment.Center
        stackView.axis = .Vertical
        view.addSubview(stackView)
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[stackView]|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: ["stackView": stackView]))
        view.addConstraint(NSLayoutConstraint(item: stackView, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant:0))
        
        status = UILabel()
        status.translatesAutoresizingMaskIntoConstraints = false
        status.text = "Submitting…"
        status.textColor = UIColor.whiteColor()
        status.font = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle1)
        status.numberOfLines = 0
        status.textAlignment = .Center
        
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        
        stackView.addArrangedSubview(status)
        stackView.addArrangedSubview(spinner)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "You're All Set!"
        navigationItem.hidesBackButton = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        doSubmission()
    }
    
    func doSubmission() {
        let submitMessageRecord = CKRecord(recordType: "Message")
        submitMessageRecord["language"] = language
        submitMessageRecord["comments"] = comments
        
        let audioURL = RecordMessageViewController.getWhistleURL()
        let MessageAsset = CKAsset(fileURL: audioURL)
        submitMessageRecord["audio"] = MessageAsset
        
        CKContainer.defaultContainer().publicCloudDatabase.saveRecord(submitMessageRecord) { [unowned self] (record, error) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil {
                    self.view.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
                    self.status.text = "Information Saved and Sent!"
                    self.spinner.stopAnimating()
                    
                    ViewController.dirty = true
                } else {
                    self.status.text = "Error: \(error!.localizedDescription)"
                    self.spinner.stopAnimating()
                }
                
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(SubmitViewController.doneTapped))
            }
        }
    }
    
    func doneTapped() {
        
        
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let subscription = CKSubscription(recordType:"Message", predicate: predicate, options: [.FiresOnRecordCreation, .FiresOnRecordUpdate, .FiresOnRecordDeletion])
        let publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
        
        let notification = CKNotificationInfo()
        notification.alertBody = "There's a new Message in  \(self.language) from the Imam."
        notification.soundName = UILocalNotificationDefaultSoundName
        
        
        
        publicDatabase.saveSubscription(subscription) { (subscription: CKSubscription?, error: NSError?) -> Void in
            guard error == nil else {
                // Handle the error here
                return
            }
            
            // Save that we have subscribed successfully to keep track and avoid trying to subscribe again
        }
    
    
           navigationController?.popToRootViewControllerAnimated(true)
    
    }
    
    
    
    
    
    
        /*let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(comments, forKey: "comments")
        
        let database = CKContainer.defaultContainer().publicCloudDatabase
        
        database.fetchAllSubscriptionsWithCompletionHandler() { [unowned self] (subscriptions, error) -> Void in
            if error == nil {
                if let subscriptions = subscriptions {
                    for subscription in subscriptions {
                       database.deleteSubscriptionWithID(subscription.subscriptionID, completionHandler: { (str, error) -> Void in
                            if error != nil {
                                
                            print(error!.localizedDescription)
                            }
                        })
                    }
                    
                    let predicate = NSPredicate(format:"comments = %@", self.comments)
                    let subscription = CKSubscription(recordType: "Message", predicate: predicate, options: .FiresOnRecordCreation)

                    
                    let notification = CKNotificationInfo()
                    notification.alertBody = "There's a new Message in  \(self.language) from the Imam."
                    notification.soundName = UILocalNotificationDefaultSoundName
                    
                    subscription.notificationInfo = notification
                    
                    database.saveSubscription(subscription) { (result, error) -> Void in
                        if error != nil {
                            print(error!.localizedDescription)
                        }
                    }
                    
                }
            }
            else {
                // do your error handling here!
                print(error!.localizedDescription)
            }
        }
        
        
        //navigationController?.popToRootViewControllerAnimated(true)
    }*/
    
   
    
}








