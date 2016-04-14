//
//  SearchViewController.swift
//
//  Created by Edwin Vermeer on 3/25/15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit
import Async

class SearchViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!

    var queryRunning: Int = 0
    var data: [Message] = []

    override func viewDidAppear(animated: Bool) {
        doFilter()
    }

    // ------------------------------------------------------------------------
    // MARK: - Search filter
    // ------------------------------------------------------------------------

    func doFilter() {
        if self.searchBar.selectedScopeButtonIndex > 0 {
            self.filterContentForSearchText(self.searchBar.text!)
        } else {
            self.filterContentForSearchTextV2(self.searchBar.text!)
        }
    }

    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        doFilter()
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        doFilter()
    }

    // Token search (search for complete words in the entire record
    func filterContentForSearchText(searchText: String) {
        EVLog("Filter for \(searchText)")
        networkSpinner(1)
        EVCloudKitDao.publicDB.query(Message(), tokens: searchText, completionHandler: { results, isFinished in
            EVLog("query for tokens '\(searchText)' result count = \(results.count)")
            self.data = results
            Async.main {
                self.tableView.reloadData()
                self.networkSpinner(-1)
            }
            return (self.data.count < 500)
        }, errorHandler: { error in
            EVLog("ERROR: query Message for words \(searchText)")
            self.networkSpinner(-1)
        })
    }

    // Just search the Message.Text field if it contains the searchText
    func filterContentForSearchTextV2(searchText: String) {
        EVLog("Filter for \(searchText)")
        networkSpinner(1)
        EVCloudKitDao.publicDB.query(Message(), predicate: NSPredicate(format: "Text BEGINSWITH %@", searchText), completionHandler: { results, isFinished in
            EVLog("query for tokens '\(searchText)' result count = \(results.count)")
            self.data = results
            Async.main {
                self.tableView.reloadData()
                self.networkSpinner(-1)
            }
            return (self.data.count < 500)
        }, errorHandler: { error in
            EVLog("ERROR: query Message for words \(searchText)")
            self.networkSpinner(-1)
        })
    }

    func networkSpinner(adjust: Int) {
        self.queryRunning = self.queryRunning + adjust
        UIApplication.sharedApplication().networkActivityIndicatorVisible = self.queryRunning > 0
    }

    // ------------------------------------------------------------------------
    // MARK: - tableView - Search result items
    // ------------------------------------------------------------------------

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "Folowin_Search_Cell";
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
                if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
            cell.selectedBackgroundView = UIView()
        }

        let item: Message = data[indexPath.row]
        cell.textLabel?.text = item.Text
        return cell;
    }
}
