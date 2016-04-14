//
//  SelectlanguageView.swift
//  Masjid Afghani
//
//  Created by Applied Sciences on 3/28/16.
//  Copyright © 2016 wahid hossaini. All rights reserved.
//

import UIKit

class SelectlanguageViewController: UITableViewController {
    static var languages = ["Arabic","Bangladish","English","Farsi","Phasto","Urdu"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Select A Language"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Language", style: .Plain, target: nil, action: nil)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SelectlanguageViewController.languages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.text = SelectlanguageViewController.languages[indexPath.row]
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            let newlanguages = cell.textLabel?.text ?? SelectlanguageViewController.languages[0]
            let vc = AddCommentsViewController()
            vc.language = newlanguages
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
