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
        let barButtonItem = UIBarButtonItem(title: "Bold", style: .plain, target: self, action: #selector(TextViewController.toggleBold))
        
        return barButtonItem
    }()
    
    lazy var italicButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Italic", style: .plain, target: self, action: #selector(TextViewController.toggleItalic))
        
        return barButtonItem
    }()
    
    lazy var bulletedListButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Bullets", style: .plain, target: self, action: #selector(TextViewController.toggleBulletedList))
        
        return barButtonItem
    }()
    
    lazy var numberedListButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Numbers", style: .plain, target: self, action: #selector(TextViewController.toggleNumberedList))
        
        return barButtonItem
    }()
    
    lazy var parseButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Parse", style: .plain, target: self, action: #selector(TextViewController.parse))
        return barButtonItem
    }()
    var parsed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChangeFrame), name: NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
        
        textView.delegate = self
        let fontSize: CGFloat = 12
        regularFont = UIFont.systemFont(ofSize: fontSize)
        boldFont = UIFont.boldSystemFont(ofSize: fontSize)
        italicFont = UIFont.italicSystemFont(ofSize: fontSize)
        boldItalicFont = UIFont(descriptor: UIFont.systemFont(ofSize: fontSize).fontDescriptor.withSymbolicTraits([.traitItalic, .traitBold])!, size: fontSize)
        
        navigationController?.isToolbarHidden = false
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        setToolbarItems([boldButton, flexibleSpace, italicButton, flexibleSpace, bulletedListButton, flexibleSpace, numberedListButton, flexibleSpace, parseButton], animated: false)
        
        let views = ["textView": textView]
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(textView)
        view.backgroundColor = .blue
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[textView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[textView]|", options: [], metrics: nil, views: views))
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
        parseButton.tintColor = parsed ? .blue : .red
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
        boldButton.tintColor = selectionContainsBold(textView.selectedRange) ? .red : .blue
        
        italicButton.tintColor = selectionContainsItalic(textView.selectedRange) ? .red : .blue
        
        bulletedListButton.tintColor = selectionContainsBulletedList(textView.selectedRange) ? .red : .blue
        
        numberedListButton.tintColor = selectionContainsNumberedList(textView.selectedRange) ? .red : .blue
    }
    
    override func textViewDidChangeSelection(_ textView: UITextView) {
        super.textViewDidChangeSelection(textView)
        
        adjustButtons()
    }
    
    // MARK: Keyboard Actions
    
    func keyboardWillChangeFrame(_ notification: Notification) {
        // 'keyboardWillChangeFrame is to catch most of the situations of the keyboard, except if it's undocked, in which case we'll have to let keyboardDidChangeFrame correct the constraint
        guard let keyboardFrameEnd = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let animationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        updateToolbarPositionForKeyboardFrame(keyboardFrameEnd, withAnimationDuration: animationDuration)
    }
    
    /// 'keyboardDidChangeFrame is to catch an undocked keyboard moving. That provides zero for the end frame on willChange, but provides a 0 for the begin frame here and the real value for the end frame
    /// This method can be deleted if you don't want to put the toolbar above the split keyboard
    func keyboardDidChangeFrame(_ notification: Notification) {
        guard let keyboardFrameBegin = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue, keyboardFrameBegin.height == 0, let keyboardFrameEnd = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let animationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        updateToolbarPositionForKeyboardFrame(keyboardFrameEnd, withAnimationDuration: animationDuration)
    }

    fileprivate func updateToolbarPositionForKeyboardFrame(_ keyboardFrame: CGRect, withAnimationDuration animationDuration: TimeInterval) {
        guard let window = view.window, let toolbar = navigationController?.toolbar else { return }
        
        // This keeps the note from looking blank and broken due to a zero frame, which means the keyboard may not be covering anything
        let maxY = view.frame.height - toolbar.bounds.size.height
        let toolbarY = min(((keyboardFrame.height > 0) ? window.convert(keyboardFrame, to: view).origin.y - toolbar.bounds.size.height : maxY), maxY)
        
        UIView.animate(withDuration: animationDuration) {
            toolbar.frame = CGRect(x: toolbar.frame.origin.x, y: toolbarY, width: toolbar.frame.width, height: toolbar.frame.height)
        }
    }
    
}
