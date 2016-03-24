//
//  TSBaseParser.swift
//  TSSwiftMarkdownParser
//
//  Created by Rhett Rogers on 3/24/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

typealias TSSwiftMarkdownParserMatchBlock = ((NSTextCheckingResult, NSMutableAttributedString) -> Void)

class TSBaseParser {
    
    var defaultAttributes = [String: AnyObject]()
    
    private var parsingPairs = [TSExpressionBlockPair]()
    
    func attributedStringFromMarkdown(markdown: String) {
        
    }
    
    func attributedStringFromMarkdown(makdown: String, attributes: [String: AnyObject]?) {
        
    }
    
    func attributedStringFromAttributedMarkdownString(attributedString: NSAttributedString) {
        
    }
    
    func addParsingRuleWithRegularExpression(regularExpression: NSRegularExpression, block: TSSwiftMarkdownParserMatchBlock) {
        TSExpressionBlockPair()
        parsingPairs.append()
    }
    
}