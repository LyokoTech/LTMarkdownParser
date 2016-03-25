//
//  TSSwiftMarkdownParser.swift
//  TSSwiftMarkdownParser
//
//  Created by Rhett Rogers on 3/24/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

typealias TSSwiftMarkdownParserFormattingBlock = ((NSMutableAttributedString, NSRange) -> Void)
typealias TSSwiftMarkdownParserLevelFormattingBlock = ((NSMutableAttributedString, NSRange, Int) -> Void)

public class TSSwiftMarkdownParser: TSBaseParser {
    
    var headerAttributes = [[String: AnyObject]]()
    var listAttributes = [[String: AnyObject]]()
    var quoteAttributes = [[String: AnyObject]]()
    
    var imageAttributes = [String: AnyObject]()
    var linkAttributes = [String: AnyObject]()
    var monospaceAttributes = [String: AnyObject]()
    var strongAttributes = [String: AnyObject]()
    var emphasisAttributes = [String: AnyObject]()
    
    static var standardParser: TSSwiftMarkdownParser = {
       return TSSwiftMarkdownParser()
    }()
    
    override init() {
//        defaultAttri
    }
    
    func addEscapingParsing() {
        
    }
    
    func addCodeEscapingParsing() {
        
    }
    
    func addHeaderParsingWithMaxLevel(maxLevel: Int, leadFormattingBlock: TSSwiftMarkdownParserFormattingBlock, textFormattingBlock formattingBlock: TSSwiftMarkdownParserLevelFormattingBlock?) {
        
    }
    
    func addListParsingWithMaxLevel(maxLevel: Int, leadFormattingBlock: TSSwiftMarkdownParserFormattingBlock, textFormattingBlock formattingBlock: TSSwiftMarkdownParserLevelFormattingBlock?) {
        
    }
    
    func addQuoteParsingWithMaxLevel(maxLevel: Int, leadFormattingBlock: TSSwiftMarkdownParserFormattingBlock, textFormattingBlock formattingBlock: TSSwiftMarkdownParserLevelFormattingBlock?) {
        
    }
    
    func addShortHeaderParsingWithMaxLevel(maxLevel: Int, leadFormattingBlock: TSSwiftMarkdownParserFormattingBlock, textFormattingBlock formattingBlock: TSSwiftMarkdownParserLevelFormattingBlock?) {
        
    }
    
    func addShortListParsingWithMaxLevel(maxLevel: Int, leadFormattingBlock: TSSwiftMarkdownParserFormattingBlock, textFormattingBlock formattingBlock: TSSwiftMarkdownParserLevelFormattingBlock?) {
        
    }
    
    func addShortQuoteParsingWithMaxLevel(maxLevel: Int, leadFormattingBlock: TSSwiftMarkdownParserFormattingBlock, textFormattingBlock formattingBlock: TSSwiftMarkdownParserLevelFormattingBlock?) {
        
    }
    
    func addImageParsingWithImageFormattingBlock(formattingBlock: TSSwiftMarkdownParserFormattingBlock, alternativeTextFormattingBlock alternateFormattingBlock: TSSwiftMarkdownParserFormattingBlock) {
        
    }
    
    func addLinkParsingWithFormattingBlock(formattingBlock: TSSwiftMarkdownParserFormattingBlock) {
        
    }
    
    func addLinkDetectionWithFormattingBlock(formattingBlock: TSSwiftMarkdownParserFormattingBlock) {
        
    }
    
    func addMonospacedParsingWithFormattingBlock(formattingBlock: TSSwiftMarkdownParserFormattingBlock) {
        
    }
    
    func addStrongParsingWithFormattingBlock(formattingBlock: TSSwiftMarkdownParserFormattingBlock) {
        
    }
    
    func addEmphasisParsingWithFormattingBlock(formattingBlock: TSSwiftMarkdownParserFormattingBlock) {
        
    }
    
    func addUnescapingParsing() {
        
    }
    
    func addCodeUnescapingParsingWithFormattingBlock(formattingBlock: TSSwiftMarkdownParserFormattingBlock) {
        
    }
    
}
