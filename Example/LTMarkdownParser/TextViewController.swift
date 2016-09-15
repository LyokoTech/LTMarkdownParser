//
//  TextViewController.swift
//  LTMarkdownParser
//
//  Created by Rhett Rogers on 4/18/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import RichTextVC_iOS
import LTMarkdownParser

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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidChangeFrame), name: UIKeyboardDidChangeFrameNotification, object: nil)
        
        textView.delegate = self
        let fontSize: CGFloat = 12
        regularFont = UIFont.systemFontOfSize(fontSize)
        boldFont = UIFont.boldSystemFontOfSize(fontSize)
        italicFont = UIFont.italicSystemFontOfSize(fontSize)
        boldItalicFont = UIFont(descriptor: UIFont.systemFontOfSize(fontSize).fontDescriptor().fontDescriptorWithSymbolicTraits([.TraitItalic, .TraitBold])!, size: fontSize)
        
        navigationController?.toolbarHidden = false
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        setToolbarItems([boldButton, flexibleSpace, italicButton, flexibleSpace, bulletedListButton, flexibleSpace, numberedListButton, flexibleSpace, parseButton], animated: false)
        
        let views = ["textView": textView]
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(textView)
        view.backgroundColor = UIColor.blueColor()
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[textView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[textView]|", options: [], metrics: nil, views: views))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        textView.becomeFirstResponder()
    }
    
    func parse() {
        if parsed {
            // Switch to attributedString
            textView.attributedText = LTMarkdownParser.standardParser.attributedStringFromMarkdown(textView.text)
        } else {
            // Switch to markdownString
            textView.attributedText = NSAttributedString(string: textView.attributedText?.markdownString() ?? "")
        }
        parseButton.tintColor = parsed ? .blueColor() : .redColor()
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
        boldButton.tintColor = selectionContainsBold(textView.selectedRange) ? .redColor() : .blueColor()
        
        italicButton.tintColor = selectionContainsItalic(textView.selectedRange) ? .redColor() : .blueColor()
        
        bulletedListButton.tintColor = selectionContainsBulletedList(textView.selectedRange) ? .redColor() : .blueColor()
        
        numberedListButton.tintColor = selectionContainsNumberedList(textView.selectedRange) ? .redColor() : .blueColor()
    }
    
    override func textViewDidChangeSelection(textView: UITextView) {
        super.textViewDidChangeSelection(textView)
        
        adjustButtons()
    }
    
    // MARK: Keyboard Actions
    
    func keyboardWillChangeFrame(notification: NSNotification) {
        // 'keyboardWillChangeFrame is to catch most of the situations of the keyboard, except if it's undocked, in which case we'll have to let keyboardDidChangeFrame correct the constraint
        guard let keyboardFrameEnd = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue() else { return }
        
        let animationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        updateToolbarPositionForKeyboardFrame(keyboardFrameEnd, withAnimationDuration: animationDuration)
    }
    
    /// 'keyboardDidChangeFrame is to catch an undocked keyboard moving. That provides zero for the end frame on willChange, but provides a 0 for the begin frame here and the real value for the end frame
    /// This method can be deleted if you don't want to put the toolbar above the split keyboard
    func keyboardDidChangeFrame(notification: NSNotification) {
        guard let keyboardFrameBegin = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue() where keyboardFrameBegin.height == 0, let keyboardFrameEnd = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue() else { return }
        
        let animationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        updateToolbarPositionForKeyboardFrame(keyboardFrameEnd, withAnimationDuration: animationDuration)
    }

    private func updateToolbarPositionForKeyboardFrame(keyboardFrame: CGRect, withAnimationDuration animationDuration: NSTimeInterval) {
        guard let window = view.window, toolbar = navigationController?.toolbar else { return }
        
        // This keeps the note from looking blank and broken due to a zero frame, which means the keyboard may not be covering anything
        let maxY = view.frame.height - toolbar.bounds.size.height
        let toolbarY = min(((keyboardFrame.height > 0) ? window.convertRect(keyboardFrame, toView: view).origin.y - toolbar.bounds.size.height : maxY), maxY)
        
        UIView.animateWithDuration(animationDuration) {
            toolbar.frame = CGRect(x: toolbar.frame.origin.x, y: toolbarY, width: toolbar.frame.width, height: toolbar.frame.height)
        }
    }
    
}
