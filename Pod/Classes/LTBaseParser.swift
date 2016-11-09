//
//  TSBaseParser.swift
//  LTMarkdownParser
//
//  Created by Rhett Rogers on 3/24/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation



open class TSBaseParser {

    public typealias LTMarkdownParserMatchBlock = ((NSTextCheckingResult, NSMutableAttributedString) -> Void)
    
    struct TSExpressionBlockPair {
        
        var regularExpression: NSRegularExpression
        var block: LTMarkdownParserMatchBlock
        
    }
    
    open var defaultAttributes = [String: Any]()
    
    fileprivate var parsingPairs = [TSExpressionBlockPair]()
    
    open func attributedStringFromMarkdown(_ markdown: String) -> NSAttributedString? {
        return attributedStringFromMarkdown(markdown, attributes: defaultAttributes)
    }
    
    open func attributedStringFromMarkdown(_ markdown: String, attributes: [String: Any]?) -> NSAttributedString? {
        var attributedString: NSAttributedString?
        if let attributes = attributes {
            attributedString = NSAttributedString(string: markdown, attributes: attributes)
        } else {
            attributedString = NSAttributedString(string: markdown)
        }
        
        return attributedStringFromAttributedMarkdownString(attributedString)
    }
    
    open func attributedStringFromAttributedMarkdownString(_ attributedString: NSAttributedString?) -> NSAttributedString? {
        guard let attributedString = attributedString else { return nil }
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
        
        for expressionBlockPair in parsingPairs {
            parseExpressionBlockPairForMutableString(mutableAttributedString, expressionBlockPair: expressionBlockPair)
        }
        
        return mutableAttributedString
    }
    
    func parseExpressionBlockPairForMutableString(_ mutableAttributedString: NSMutableAttributedString, expressionBlockPair: TSExpressionBlockPair) {
        parseExpressionForMutableString(mutableAttributedString, expression: expressionBlockPair.regularExpression, block: expressionBlockPair.block)
    }
    
    func parseExpressionForMutableString(_ mutableAttributedString: NSMutableAttributedString, expression: NSRegularExpression, block: LTMarkdownParserMatchBlock) {
        var location = 0
        
        while let match = expression.firstMatch(in: mutableAttributedString.string, options: .withoutAnchoringBounds, range: NSRange(location: location, length: mutableAttributedString.length - location)) {
            let oldLength = mutableAttributedString.length
            block(match, mutableAttributedString)
            let newLength = mutableAttributedString.length
            location = match.range.location + match.range.length + newLength - oldLength
        }
    }
    
    open func addParsingRuleWithRegularExpression(_ regularExpression: NSRegularExpression, block: @escaping LTMarkdownParserMatchBlock) {
        parsingPairs.append(TSExpressionBlockPair(regularExpression: regularExpression, block: block))
    }
    
}
