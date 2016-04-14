//
//  AppDelegate.swift
//  Masjid Afghani
//
//  Created by Applied Sciences on 3/28/16.
//  Copyright © 2016 wahid hossaini. All rights reserved.
//

import CloudKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Push notification setup
        let notificationSettings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert, categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
        application.registerForRemoteNotifications()
        
        // Your code here
        
        return true
    }
    
        /*func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        return true
    }*/
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        let cloudKitNotification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String : NSObject])
        
        if let pushInfo = userInfo as? [String: NSObject] {
            let notification = CKNotification(fromRemoteNotificationDictionary: pushInfo)
            
            let ac = UIAlertController(title:"New Notification Message from the Imam?", message: notification.alertBody, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        }
        
        
        if cloudKitNotification.notificationType == .Query {
            let queryNotification = cloudKitNotification as! CKQueryNotification
            if queryNotification.queryNotificationReason == .RecordDeleted {
                // If the record has been deleted in CloudKit then delete the local copy here
            } else {
                // If the record has been created or changed, we fetch the data from CloudKit
                
                let database: CKDatabase
                if queryNotification.isPublicDatabase {
                    database = CKContainer.defaultContainer().publicCloudDatabase
                } else {
                    database = CKContainer.defaultContainer().privateCloudDatabase
                }
                database.fetchRecordWithID(queryNotification.recordID!, completionHandler: { (record: CKRecord?, error: NSError?) -> Void in
                    guard error == nil else {
                        // Handle the error here
                        return
                    }
                    
                    if queryNotification.queryNotificationReason == .RecordUpdated {
                        // Use the information in the record object to modify your local data
                    } else {
                        // Use the information in the record object to create a new local object
                    }
                })
            }
        }
    }
    
    func fetchNotificationChanges() {
        let operation = CKFetchNotificationChangesOperation(previousServerChangeToken: nil)
        
        var notificationIDsToMarkRead = [CKNotificationID]()
        
        operation.notificationChangedBlock = { (notification: CKNotification) -> Void in
            // Process each notification received
            if notification.notificationType == .Query {
                let queryNotification = notification as! CKQueryNotification
                let reason = queryNotification.queryNotificationReason
                let recordID = queryNotification.recordID
                
                // Do your process here depending on the reason of the change
                
                // Add the notification id to the array of processed notifications to mark them as read
                notificationIDsToMarkRead.append(queryNotification.notificationID!)
            }
        }
        
        operation.fetchNotificationChangesCompletionBlock = { (serverChangeToken: CKServerChangeToken?, operationError: NSError?) -> Void in
            guard operationError == nil else {
                // Handle the error here
                return
            }
            
            // Mark the notifications as read to avoid processing them again
            let markOperation = CKMarkNotificationsReadOperation(notificationIDsToMarkRead: notificationIDsToMarkRead)
            markOperation.markNotificationsReadCompletionBlock = { (notificationIDsMarkedRead: [CKNotificationID]?, operationError: NSError?) -> Void in
                guard operationError == nil else {
                    // Handle the error here
                    return
                }
            }
            
            let operationQueue = NSOperationQueue()
            operationQueue.addOperation(markOperation)
        }
        
        let operationQueue = NSOperationQueue()
        operationQueue.addOperation(operation)
    }
    
    
    
    /*func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if let pushInfo = userInfo as? [String: NSObject] {
            let notification = CKNotification(fromRemoteNotificationDictionary: pushInfo)
            
            let ac = UIAlertController(title:"New Notification Message from the Imam?", message: notification.alertBody, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            
            if let nc = window?.rootViewController as? UINavigationController {
                if let vc = nc.visibleViewController {
                    vc.presentViewController(ac, animated: true, completion: nil)
                }
            }
        }
    }*/
}

