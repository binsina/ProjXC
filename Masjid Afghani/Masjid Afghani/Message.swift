//
//  Message.swift
//  Masjid Afghani
//
//  Created by Applied Sciences on 3/28/16.
//  Copyright © 2016 wahid hossaini. All rights reserved.
//

import CloudKit
import UIKit

class Message: NSObject {
    var recordID: CKRecordID!
    var language: String!
    var comments: String!
    var audio: NSURL!
}