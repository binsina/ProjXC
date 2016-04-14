//
//  AddCommentsView.swift
//  Masjid Afghani
//
//  Created by Applied Sciences on 3/28/16.
//  Copyright © 2016 wahid hossaini. All rights reserved.
//

import UIKit

class AddCommentsViewController: UIViewController, UITextViewDelegate {
    var language: String!
    
    var comments: UITextView!
    let placeholder = "Please Type any important information that might be helpful for the people to attend the Janazah or Burial."
    
    override func loadView() {
        super.loadView()
        
        comments = UITextView()
        comments.translatesAutoresizingMaskIntoConstraints = false
        comments.delegate = self
        comments.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        view.addSubview(comments)
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[comments]|", options: .AlignAllCenterX, metrics: nil, views: ["comments": comments]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[comments]|", options: .AlignAllCenterX, metrics: nil, views: ["comments": comments]))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Written A Message"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .Plain, target: self, action: #selector(AddCommentsViewController.submitTapped))
        comments.text = placeholder
    }
    
    func submitTapped() {
        let vc = SubmitViewController()
        vc.language = language
        
        if comments.text == placeholder {
            vc.comments = ""
        } else {
            vc.comments = comments.text
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == placeholder {
            textView.text = ""
        }
    }
}
