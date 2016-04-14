//
//  myLanguageView.swift
//  Masjid Afghani
//
//  Created by Applied Sciences on 3/28/16.
//  Copyright © 2016 wahid hossaini. All rights reserved.
//

import CloudKit
import UIKit

class myLanguageViewController: UITableViewController {
    
    
    var myGenres: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let savedGenres = defaults.objectForKey("myGenres") as? [String] {
            myGenres = savedGenres
        } else {
            myGenres = [String]()
        }
        
        title = "Notify me about…"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: #selector(myLanguageViewController.saveTapped))
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SelectlanguageViewController.languages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let myLanguageSelection = SelectlanguageViewController.languages[indexPath.row]
        cell.textLabel?.text = myLanguageSelection
        
        if myGenres.contains(myLanguageSelection) {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            let selectedGenre = SelectlanguageViewController.languages[indexPath.row]
            
            if cell.accessoryType == .None {
                cell.accessoryType = .Checkmark
                myGenres.append(selectedGenre)
            } else {
                cell.accessoryType = .None
                
                if let index = myGenres.indexOf(selectedGenre) {
                    myGenres.removeAtIndex(index)
                }
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func saveTapped() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(myGenres, forKey: "myGenres")
        
        let database = CKContainer.defaultContainer().publicCloudDatabase
        
        database.fetchAllSubscriptionsWithCompletionHandler() { [unowned self] (subscriptions, error) -> Void in
            if error == nil {
                if let subscriptions = subscriptions {
                    for subscription in subscriptions {
                        database.deleteSubscriptionWithID(subscription.subscriptionID, completionHandler: { (str, error) -> Void in
                            if error != nil {
                                // do your error handling here!
                                print(error!.localizedDescription)
                            }
                        })
                    }
                    
                    for myLanguageSelection in self.myGenres {
                        let predicate = NSPredicate(format:"language = %@", myLanguageSelection)
                        let subscription = CKSubscription(recordType: "Message", predicate: predicate, options: .FiresOnRecordCreation)
                        
                        let notification = CKNotificationInfo()
                        notification.alertBody = "There's a new Janazah in the \(myLanguageSelection) Notice Section."
                        notification.soundName = UILocalNotificationDefaultSoundName
                        
                        subscription.notificationInfo = notification
                        
                        database.saveSubscription(subscription) { (result, error) -> Void in
                            if error != nil {
                                print(error!.localizedDescription)
                            }
                        }
                    }
                }
            } else {
                // do your error handling here!
                print(error!.localizedDescription)
            }
        }
    }
}
