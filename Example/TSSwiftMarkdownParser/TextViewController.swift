//
//  TextViewController.swift
//  TSSwiftMarkdownParser
//
//  Created by Rhett Rogers on 4/18/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import RichTextVC_iOS
import TSSwiftMarkdownParser

class TextViewController: RichTextViewController {
    
    lazy var boldButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Bold", style: .Plain, target: self, action: #selector(TextViewController.toggleBold))
        
        return barButtonItem
    }()
    
    lazy var italicButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Italic", style: .Plain, target: self, action: #selector(TextViewController.toggleItalic))
        
        return barButtonItem
    }()
    
    lazy var bulletedListButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Bullets", style: .Plain, target: self, action: #selector(TextViewController.toggleBulletedList))
        
        return barButtonItem
    }()
    
    lazy var numberedListButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Numbers", style: .Plain, target: self, action: #selector(TextViewController.toggleNumberedList))
        
        return barButtonItem
    }()
    
    lazy var parseButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Parse", style: .Plain, target: self, action: #selector(TextViewController.parse))
        return barButtonItem
    }()
    var parsed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        let fontSize: CGFloat = 12
        regularFont = UIFont.systemFontOfSize(fontSize)
        boldFont = UIFont.boldSystemFontOfSize(fontSize)
        italicFont = UIFont.italicSystemFontOfSize(fontSize)
        boldItalicFont = UIFont(descriptor: UIFont.systemFontOfSize(fontSize).fontDescriptor().fontDescriptorWithSymbolicTraits([.TraitItalic, .TraitBold]), size: fontSize)
        
        navigationController?.toolbarHidden = false
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        setToolbarItems([boldButton, flexibleSpace, italicButton, flexibleSpace, bulletedListButton, flexibleSpace, numberedListButton, flexibleSpace, parseButton], animated: false)
        
        let views = ["textView": textView]
        textView.translatesAutoresizingMaskIntoConstraints = false
//        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        view.backgroundColor = UIColor.blueColor()
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[textView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[textView]|", options: [], metrics: nil, views: views))
        textView.becomeFirstResponder()
    }
    
    func parse() {
        if parsed {
            //Switch to attributedString
            textView.attributedText = TSSwiftMarkdownParser.standardParser.attributedStringFromMarkdown(textView.text)
        } else {
            //Switch to markdownString
            textView.attributedText = NSAttributedString(string: textView.attributedText?.markdownString() ?? "")
        }
        parseButton.tintColor = parsed ? UIColor.blueColor() : UIColor.redColor()
        parsed = !parsed
    }
    
    
    override func toggleBold() {
        super.toggleBold()
        adjustButtons()
    }
    
    override func toggleItalic() {
        super.toggleItalic()
        adjustButtons()
    }
    
    override func toggleBulletedList() {
        super.toggleBulletedList()
        adjustButtons()
    }
    
    override func toggleNumberedList() {
        super.toggleNumberedList()
        adjustButtons()
    }
   
    func adjustButtons() {
        boldButton.tintColor = selectionContainsBold(textView.selectedRange) ? UIColor.redColor() : UIColor.blueColor()
        
        italicButton.tintColor = selectionContainsItalic(textView.selectedRange) ? UIColor.redColor() : UIColor.blueColor()
        
        bulletedListButton.tintColor = selectionContainsBulletedList(textView.selectedRange) ? UIColor.redColor() : UIColor.blueColor()
        
        numberedListButton.tintColor = selectionContainsNumberedList(textView.selectedRange) ? UIColor.redColor() : UIColor.blueColor()
    }
    
    override func textViewDidChangeSelection(textView: UITextView) {
        super.textViewDidChangeSelection(textView)
        
        adjustButtons()
    }
    
}
