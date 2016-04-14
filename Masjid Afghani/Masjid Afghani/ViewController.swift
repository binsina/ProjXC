//
//  ViewController.swift
//  Masjid Afghani
//
//  Created by Applied Sciences on 3/28/16.
//  Copyright © 2016 wahid hossaini. All rights reserved.
//

import CloudKit
import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    static var dirty = true
    
    var tableView: UITableView!
    
    var JanazahMessage = [Message]()
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = UIColor.whiteColor()
        
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[tableView]|", options: .AlignAllCenterX, metrics: nil, views: ["tableView": tableView]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[guide][tableView]|", options: .AlignAllCenterX, metrics: nil, views: ["guide": topLayoutGuide, "tableView": tableView]))
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Syed J. Afghani"
        //navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Personal Notices", style: .Plain, target: self, action: #selector(ViewController.selectGenre))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(ViewController.addWhistle))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Home", style: .Plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        if ViewController.dirty {
            loadMessage()
        }
    }
    
    func makeAttributedString(title title: String, subtitle: String) -> NSAttributedString {
        let titleAttributes = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline), NSForegroundColorAttributeName: UIColor.purpleColor()]
        let subtitleAttributes = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)]
        
        let titleString = NSMutableAttributedString(string: "\(title)", attributes: titleAttributes)
        
        if subtitle.characters.count > 0 {
            let subtitleString = NSAttributedString(string: "\n\(subtitle)", attributes: subtitleAttributes)
            titleString.appendAttributedString(subtitleString)
        }
        
        return titleString
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.JanazahMessage.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.accessoryType = .DisclosureIndicator
        cell.textLabel?.attributedText =  makeAttributedString(title: JanazahMessage[indexPath.row].language, subtitle: JanazahMessage[indexPath.row].comments)
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = ResultsViewController()
        vc.resultsMessage = JanazahMessage[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func loadMessage() {
        let pred = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "creationDate", ascending: false)
        let query = CKQuery(recordType: "Message", predicate: pred)
        query.sortDescriptors = [sort]
        
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["language", "comments"]
        operation.resultsLimit = 50
        
        var newMessage = [Message]()
        
        operation.recordFetchedBlock = { (record) in
            let CKMessage = Message()
            CKMessage.recordID = record.recordID
            CKMessage.language = record["language"] as! String
            CKMessage.comments = record["comments"] as! String
            newMessage.append(CKMessage)
        }
        
        operation.queryCompletionBlock = { [unowned self] (cursor, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil {
                    ViewController.dirty = false
                    self.JanazahMessage = newMessage
                    self.tableView.reloadData()
                } else {
                    let ac = UIAlertController(title: "Fetch failed", message: "There was a problem fetching the Message; please shutdown app and try again: \(error!.localizedDescription)", preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(ac, animated: true, completion: nil)
                }
            }
        }
        
        CKContainer.defaultContainer().publicCloudDatabase.addOperation(operation)
    }
    
    func addWhistle() {
     
         let ac = UIAlertController(title: "Please Type in the Password to create a New Notification", message: nil, preferredStyle: .Alert)
        var suggestion: UITextField!
        
        ac.addTextFieldWithConfigurationHandler { (textField) -> Void in
            suggestion = textField
            textField.autocorrectionType = .Yes
            }
        ac.addAction(UIAlertAction(title: "Submit", style: .Default) { (action) -> Void in
            if (suggestion.text == "code") {
                
                let vc = RecordMessageViewController()
                self.navigationController!.pushViewController(vc, animated: true)
            }
            else {
                let ac = UIAlertController(title: "Error", message: "You have Entered the Wrong password, Try Again", preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(ac, animated: true, completion: nil)
            }

        })
        
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    

           }
    
  

}
