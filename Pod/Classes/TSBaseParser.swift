//
//  TSBaseParser.swift
//  TSSwiftMarkdownParser
//
//  Created by Rhett Rogers on 3/24/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

typealias TSSwiftMarkdownParserMatchBlock = ((NSTextCheckingResult, NSMutableAttributedString) -> Void)

public class TSBaseParser {

    struct TSExpressionBlockPair {
        
        var regularExpression: NSRegularExpression
        var block: TSSwiftMarkdownParserMatchBlock
        
    }
    
    var defaultAttributes = [String: AnyObject]()
    
    private var parsingPairs = [TSExpressionBlockPair]()
    
    func attributedStringFromMarkdown(markdown: String) -> NSAttributedString? {
        return attributedStringFromMarkdown(markdown, attributes: defaultAttributes)
    }
    
    func attributedStringFromMarkdown(markdown: String, attributes: [String: AnyObject]?) -> NSAttributedString? {
        var attributedString: NSAttributedString?
        if let attributes = attributes {
            attributedString = NSAttributedString(string: markdown, attributes: attributes)
        } else {
            attributedString = NSAttributedString(string: markdown)
        }
        
        return attributedStringFromAttributedMarkdownString(attributedString)
    }
    
    func attributedStringFromAttributedMarkdownString(attributedString: NSAttributedString?) -> NSAttributedString? {
        guard let attributedString = attributedString else { return nil }
        
        return attributedString
    }
    
    func addParsingRuleWithRegularExpression(regularExpression: NSRegularExpression, block: TSSwiftMarkdownParserMatchBlock) {
        parsingPairs.append(TSExpressionBlockPair(regularExpression: regularExpression, block: block))
    }
    
}