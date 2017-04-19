//
//  LTMarkdownParser.swift
//  LTMarkdownParser
//
//  Created by Rhett Rogers on 3/24/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

private let nonBreakingSpaceCharacter = Character("\u{00A0}")

public struct TSSwiftMarkdownRegex {
    public static let Escaping = "\\\\."
    public static let Unescaping = "\\\\[0-9a-z]{4}"
    
    public static let Header = "^(#{1,%@})\\s+(.+)$"
    public static let ShortHeader = "^(#{1,%@})\\s*([^#].*)$"
    public static let List = "^( {0,%@})[\\*\\+\\-]\\s+(.+)$"
    public static let ShortList = "^( {0,%@})[\\*\\+\\-]\\s+([^\\*\\+\\-].*)$"
    public static let NumberedList = "^( {0,})[0-9]+\\.\\s(.+)$"
    public static let Quote = "^(\\>{1,%@})\\s+(.+)$"
    public static let ShortQuote = "^(\\>{1,%@})\\s*([^\\>].*)$"
    
    public static let Image = "\\!\\[[^\\[]*?\\]\\(\\S*\\)"
    public static let Link = "\\[[^\\[]*?\\]\\([^\\)]*\\)"
    
    public static let Monospace = "(`+)(\\s*.*?[^`]\\s*)(\\1)(?!`)"
    public static let Strong = "(\\*\\*|__)(.+?)(\\1)"
    public static let Emphasis = "(\\*|_)(.+?)(\\1)"
    public static let StrongAndEmphasis = "(((\\*\\*\\*)(.|\\s)*(\\*\\*\\*))|((___)(.|\\s)*(___)))"
    
    public static func regexForString(_ regexString: String, options: NSRegularExpression.Options = []) -> NSRegularExpression? {
        do {
            return try NSRegularExpression(pattern: regexString, options: options)
        } catch {
            return nil
        }
    }
}

open class LTMarkdownParser: TSBaseParser {
    
    public typealias LTMarkdownParserFormattingBlock = ((NSMutableAttributedString, NSRange) -> Void)
    public typealias LTMarkdownParserLevelFormattingBlock = ((NSMutableAttributedString, NSRange, Int) -> Void)
    
    open var headerAttributes = [[String: Any]]()
    open var listAttributes = [[String: Any]]()
    open var numberedListAttributes = [[String: Any]]()
    open var quoteAttributes = [[String: Any]]()
    
    open var imageAttributes = [String: Any]()
    open var linkAttributes = [String: Any]()
    open var monospaceAttributes = [String: Any]()
    open var strongAttributes = [String: Any]()
    open var emphasisAttributes = [String: Any]()
    open var strongAndEmphasisAttributes = [String: Any]()
    
    open static var standardParser = LTMarkdownParser()
    
    class func addAttributes(_ attributesArray: [[String: Any]], atIndex level: Int, toString attributedString: NSMutableAttributedString, range: NSRange) {
        guard !attributesArray.isEmpty else { return }
        
        guard let newAttributes = level < attributesArray.count && level >= 0 ? attributesArray[level] : attributesArray.last else { return }
        
        attributedString.addAttributes(newAttributes, range: range)
    }
    
    public init(withDefaultParsing: Bool = true) {
        super.init()
        
        defaultAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 12), NSParagraphStyleAttributeName: NSParagraphStyle()]
        headerAttributes = [
            [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 23)],
            [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 21)],
            [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 19)],
            [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 17)],
            [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15)],
            [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 13)]
        ]
        
        linkAttributes = [
            NSForegroundColorAttributeName: UIColor.blue,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue as AnyObject
        ]
        
        monospaceAttributes = [
            NSFontAttributeName: UIFont(name: "Menlo", size: 12) ?? UIFont.systemFont(ofSize: 12),
            NSForegroundColorAttributeName: UIColor(red: 0.95, green: 0.54, blue: 0.55, alpha: 1)
        ]
        
        strongAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12)]
        emphasisAttributes = [NSFontAttributeName: UIFont.italicSystemFont(ofSize: 12)]
        
        var strongAndEmphasisFont = UIFont.systemFont(ofSize: 12)
        strongAndEmphasisFont = UIFont(descriptor: strongAndEmphasisFont.fontDescriptor.withSymbolicTraits([.traitItalic, .traitBold])!, size: strongAndEmphasisFont.pointSize)
        strongAndEmphasisAttributes = [NSFontAttributeName: strongAndEmphasisFont]
        
        if withDefaultParsing {
            addNumberedListParsingWithLeadFormattingBlock({ (attributedString, range, level) in
                LTMarkdownParser.addAttributes(self.numberedListAttributes, atIndex: level - 1, toString: attributedString, range: range)
                let substring = attributedString.attributedSubstring(from: range).string.replacingOccurrences(of: " ", with: "\(nonBreakingSpaceCharacter)")
                attributedString.replaceCharacters(in: range, with: "\(substring)")
            }, textFormattingBlock: { attributedString, range, level in
                LTMarkdownParser.addAttributes(self.numberedListAttributes, atIndex: level - 1, toString: attributedString, range: range)
            })
            
            addEscapingParsing()
            addCodeEscapingParsing()
            
            addHeaderParsingWithLeadFormattingBlock({ attributedString, range, level in
                attributedString.replaceCharacters(in: range, with: "")
            }, textFormattingBlock: { attributedString, range, level in
                LTMarkdownParser.addAttributes(self.headerAttributes, atIndex: level - 1, toString: attributedString, range: range)
            })
            
            addListParsingWithLeadFormattingBlock({ attributedString, range, level in
                LTMarkdownParser.addAttributes(self.listAttributes, atIndex: level - 1, toString: attributedString, range: range)
                let indentString = String(repeating: String(nonBreakingSpaceCharacter), count: level)
                attributedString.replaceCharacters(in: range, with: "\(indentString)\u{2022}\u{00A0}")
            }, textFormattingBlock: { attributedString, range, level in
                LTMarkdownParser.addAttributes(self.listAttributes, atIndex: level - 1, toString: attributedString, range: range)
            })
            
            addQuoteParsingWithLeadFormattingBlock({ attributedString, range, level in
                let indentString = String(repeating: "\t", count: level)
                attributedString.replaceCharacters(in: range, with: indentString)
            }, textFormattingBlock: { attributedString, range, level in
                LTMarkdownParser.addAttributes(self.quoteAttributes, atIndex: level - 1, toString: attributedString, range: range)
            })
            
            addImageParsingWithImageFormattingBlock(nil) { attributedString, range in
                attributedString.addAttributes(self.imageAttributes, range: range)
            }
            
            addLinkParsingWithFormattingBlock { attributedString, range in
                attributedString.addAttributes(self.linkAttributes, range: range)
            }
            
            addLinkDetectionWithFormattingBlock { attributedString, range in
                attributedString.addAttributes(self.linkAttributes, range: range)
            }
            
            addStrongParsingWithFormattingBlock { attributedString, range in
                attributedString.enumerateAttributes(in: range, options: []) { attributes, range, _ in
                    if let font = attributes[NSFontAttributeName] as? UIFont, let italicFont = self.emphasisAttributes[NSFontAttributeName] as? UIFont, font == italicFont {
                        attributedString.addAttributes(self.strongAndEmphasisAttributes, range: range)
                    } else {
                        attributedString.addAttributes(self.strongAttributes, range: range)
                    }
                }
            }
            
            addEmphasisParsingWithFormattingBlock { attributedString, range in
                attributedString.enumerateAttributes(in: range, options: []) { attributes, range, _ in
                    if let font = attributes[NSFontAttributeName] as? UIFont, let boldFont = self.strongAttributes[NSFontAttributeName] as? UIFont, font == boldFont {
                        attributedString.addAttributes(self.strongAndEmphasisAttributes, range: range)
                    } else {
                        attributedString.addAttributes(self.emphasisAttributes, range: range)
                    }
                }
            }
            
            addStrongAndEmphasisParsingWithFormattingBlock { attributedString, range in
                attributedString.addAttributes(self.strongAndEmphasisAttributes, range: range)
            }
            
            addCodeUnescapingParsingWithFormattingBlock { attributedString, range in
                attributedString.addAttributes(self.monospaceAttributes, range: range)
            }
            
            addUnescapingParsing()
        }
    }
    
    open func addEscapingParsing() {
        guard let escapingRegex = TSSwiftMarkdownRegex.regexForString(TSSwiftMarkdownRegex.Escaping) else { return }
        
        addParsingRuleWithRegularExpression(escapingRegex) { match, attributedString in
            let range = NSRange(location: match.range.location + 1, length: 1)
            let matchString = attributedString.attributedSubstring(from: range).string as NSString
            let escapedString = NSString(format: "%04x", matchString.character(at: 0)) as String
            attributedString.replaceCharacters(in: range, with: escapedString)
        }
    }
    
    open func addCodeEscapingParsing() {
        guard let codingParsingRegex = TSSwiftMarkdownRegex.regexForString(TSSwiftMarkdownRegex.Monospace) else { return }
        
        addParsingRuleWithRegularExpression(codingParsingRegex) { match, attributedString in
            let range = match.rangeAt(2)
            let matchString = attributedString.attributedSubstring(from: range).string as NSString
            
            var escapedString = ""
            for index in 0..<range.length {
                escapedString = "\(escapedString)\(NSString(format: "%04x", matchString.character(at: index)))"
            }

            attributedString.replaceCharacters(in: range, with: escapedString)
        }
    }
    
    fileprivate func addLeadParsingWithPattern(_ pattern: String, maxLevel: Int?, leadFormattingBlock: @escaping LTMarkdownParserLevelFormattingBlock, formattingBlock: LTMarkdownParserLevelFormattingBlock?) {
        let regexString: String = {
            let maxLevel: Int = maxLevel ?? 0
            return NSString(format: pattern as NSString, maxLevel > 0 ? "\(maxLevel)" : "") as String
        }()
        
        guard let regex = TSSwiftMarkdownRegex.regexForString(regexString, options: .anchorsMatchLines) else { return }
        
        addParsingRuleWithRegularExpression(regex) { match, attributedString in
            let level = match.rangeAt(1).length
            formattingBlock?(attributedString, match.rangeAt(2), level)
            leadFormattingBlock(attributedString, NSRange(location: match.rangeAt(1).location, length: match.rangeAt(2).location - match.rangeAt(1).location), level)
        }
    }
    
    open func addHeaderParsingWithLeadFormattingBlock(_ leadFormattingBlock: @escaping LTMarkdownParserLevelFormattingBlock, maxLevel: Int? = nil, textFormattingBlock formattingBlock: LTMarkdownParserLevelFormattingBlock?) {
        addLeadParsingWithPattern(TSSwiftMarkdownRegex.Header, maxLevel: maxLevel, leadFormattingBlock: leadFormattingBlock, formattingBlock: formattingBlock)
    }
    
    open func addListParsingWithLeadFormattingBlock(_ leadFormattingBlock: @escaping LTMarkdownParserLevelFormattingBlock, maxLevel: Int? = nil, textFormattingBlock formattingBlock: LTMarkdownParserLevelFormattingBlock?) {
        addLeadParsingWithPattern(TSSwiftMarkdownRegex.List, maxLevel: maxLevel, leadFormattingBlock: leadFormattingBlock, formattingBlock: formattingBlock)
    }
    
    open func addNumberedListParsingWithLeadFormattingBlock(_ leadFormattingBlock: @escaping LTMarkdownParserLevelFormattingBlock, maxLevel: Int? = nil, textFormattingBlock formattingBlock: LTMarkdownParserLevelFormattingBlock?) {
        addLeadParsingWithPattern(TSSwiftMarkdownRegex.NumberedList, maxLevel: maxLevel, leadFormattingBlock: leadFormattingBlock, formattingBlock: formattingBlock)
    }
    
    open func addQuoteParsingWithLeadFormattingBlock(_ leadFormattingBlock: @escaping LTMarkdownParserLevelFormattingBlock, maxLevel: Int? = nil, textFormattingBlock formattingBlock: LTMarkdownParserLevelFormattingBlock?) {
        addLeadParsingWithPattern(TSSwiftMarkdownRegex.Quote, maxLevel: maxLevel, leadFormattingBlock: leadFormattingBlock, formattingBlock: formattingBlock)
    }
    
    open func addShortHeaderParsingWithLeadFormattingBlock(_ leadFormattingBlock: @escaping LTMarkdownParserLevelFormattingBlock, maxLevel: Int? = nil, textFormattingBlock formattingBlock: LTMarkdownParserLevelFormattingBlock?) {
        addLeadParsingWithPattern(TSSwiftMarkdownRegex.ShortHeader, maxLevel: maxLevel, leadFormattingBlock: leadFormattingBlock, formattingBlock: formattingBlock)
    }
    
    open func addShortListParsingWithLeadFormattingBlock(_ leadFormattingBlock: @escaping LTMarkdownParserLevelFormattingBlock, maxLevel: Int? = nil, textFormattingBlock formattingBlock: LTMarkdownParserLevelFormattingBlock?) {
        addLeadParsingWithPattern(TSSwiftMarkdownRegex.ShortList, maxLevel: maxLevel, leadFormattingBlock: leadFormattingBlock, formattingBlock: formattingBlock)
    }
    
    open func addShortQuoteParsingWithLeadFormattingBlock(_ leadFormattingBlock: @escaping LTMarkdownParserLevelFormattingBlock, maxLevel: Int? = nil, textFormattingBlock formattingBlock: LTMarkdownParserLevelFormattingBlock?) {
        addLeadParsingWithPattern(TSSwiftMarkdownRegex.ShortQuote, maxLevel: maxLevel, leadFormattingBlock: leadFormattingBlock, formattingBlock: formattingBlock)
    }
    
    open func addImageParsingWithImageFormattingBlock(_ formattingBlock: LTMarkdownParserFormattingBlock?, alternativeTextFormattingBlock alternateFormattingBlock: LTMarkdownParserFormattingBlock?) {
        guard let headerRegex = TSSwiftMarkdownRegex.regexForString(TSSwiftMarkdownRegex.Image, options: .dotMatchesLineSeparators) else { return }
        
        addParsingRuleWithRegularExpression(headerRegex) { match, attributedString in
            let imagePathStart = (attributedString.string as NSString).range(of: "(", options: [], range: match.range).location
            let linkRange = NSRange(location: imagePathStart, length: match.range.length + match.range.location - imagePathStart - 1)
            let imagePath = (attributedString.string as NSString).substring(with: NSRange(location: linkRange.location + 1, length: linkRange.length - 1))
            
            if let image = UIImage(named: imagePath) {
                let imageAttatchment = NSTextAttachment()
                imageAttatchment.image = image
                imageAttatchment.bounds = CGRect(x: 0, y: -5, width: image.size.width, height: image.size.height)
                let imageString = NSAttributedString(attachment: imageAttatchment)
                attributedString.replaceCharacters(in: match.range, with: imageString)
                formattingBlock?(attributedString, NSRange(location: match.range.location, length: imageString.length))
            } else {
                let linkTextEndLocation = (attributedString.string as NSString).range(of: "]", options: [], range: match.range).location
                let linkTextRange = NSRange(location: match.range.location + 2, length: linkTextEndLocation - match.range.location - 2)
                let alternativeText = (attributedString.string as NSString).substring(with: linkTextRange)
                attributedString.replaceCharacters(in: match.range, with: alternativeText)
                alternateFormattingBlock?(attributedString, NSRange(location: match.range.location, length: (alternativeText as NSString).length))
            }
        }
    }
    
    open func addLinkParsingWithFormattingBlock(_ formattingBlock: @escaping LTMarkdownParserFormattingBlock) {
        guard let linkRegex = TSSwiftMarkdownRegex.regexForString(TSSwiftMarkdownRegex.Link, options: .dotMatchesLineSeparators) else { return }
        
        addParsingRuleWithRegularExpression(linkRegex) { match, attributedString in
            let linkStartinResult = (attributedString.string as NSString).range(of: "(", options: .backwards, range: match.range).location
            let linkRange = NSRange(location: linkStartinResult, length: match.range.length + match.range.location - linkStartinResult - 1)
            let linkURLString = (attributedString.string as NSString).substring(with: NSRange(location: linkRange.location + 1, length: linkRange.length - 1))
            
            let linkTextRange = NSRange(location: match.range.location + 1, length: linkStartinResult - match.range.location - 2)
            attributedString.deleteCharacters(in: NSRange(location: linkRange.location - 1, length: linkRange.length + 2))
            
            let urlCharacterSet: NSMutableCharacterSet = NSMutableCharacterSet(charactersIn: "")
            urlCharacterSet.formUnion(with: CharacterSet.urlPathAllowed)
            urlCharacterSet.formUnion(with: CharacterSet.urlPathAllowed)
            urlCharacterSet.formUnion(with: CharacterSet.urlQueryAllowed)
            urlCharacterSet.formUnion(with: CharacterSet.urlFragmentAllowed)
            
            if let URL = URL(string: linkURLString) ?? URL(string: linkURLString.addingPercentEncoding(withAllowedCharacters: urlCharacterSet as CharacterSet) ?? linkURLString) {
                attributedString.addAttribute(NSLinkAttributeName, value: URL, range: linkTextRange)
            }
            formattingBlock(attributedString, linkTextRange)
            
            attributedString.deleteCharacters(in: NSRange(location: match.range.location, length: 1))
        }
    }
    
    fileprivate func addEnclosedParsingWithPattern(_ pattern: String, formattingBlock: @escaping LTMarkdownParserFormattingBlock) {
        guard let regex = TSSwiftMarkdownRegex.regexForString(pattern) else { return }
        
        addParsingRuleWithRegularExpression(regex) { match, attributedString in
            attributedString.deleteCharacters(in: match.rangeAt(3))
            formattingBlock(attributedString, match.rangeAt(2))
            attributedString.deleteCharacters(in: match.rangeAt(1))
        }
    }
    
    open func addMonospacedParsingWithFormattingBlock(_ formattingBlock: @escaping LTMarkdownParserFormattingBlock) {
        addEnclosedParsingWithPattern(TSSwiftMarkdownRegex.Monospace, formattingBlock: formattingBlock)
    }
    
    open func addStrongParsingWithFormattingBlock(_ formattingBlock: @escaping LTMarkdownParserFormattingBlock) {
        addEnclosedParsingWithPattern(TSSwiftMarkdownRegex.Strong, formattingBlock: formattingBlock)
    }
    
    open func addEmphasisParsingWithFormattingBlock(_ formattingBlock: @escaping LTMarkdownParserFormattingBlock) {
        addEnclosedParsingWithPattern(TSSwiftMarkdownRegex.Emphasis, formattingBlock: formattingBlock)
    }
    
    open func addStrongAndEmphasisParsingWithFormattingBlock(_ formattingBlock: @escaping LTMarkdownParserFormattingBlock) {
        addEnclosedParsingWithPattern(TSSwiftMarkdownRegex.StrongAndEmphasis, formattingBlock: formattingBlock)
    }
    
    open func addLinkDetectionWithFormattingBlock(_ formattingBlock: @escaping LTMarkdownParserFormattingBlock) {
        do {
            let linkDataDetector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            addParsingRuleWithRegularExpression(linkDataDetector) { match, attributedString in
                if let url = match.url {
                    attributedString.addAttribute(NSLinkAttributeName, value: url, range: match.range)
                }
                formattingBlock(attributedString, match.range)
            }
        } catch { }
    }
    
    fileprivate class func stringWithHexaString(_ hexaString: String, atIndex index: Int) -> String {
        let range = hexaString.characters.index(hexaString.startIndex, offsetBy: index)..<hexaString.characters.index(hexaString.startIndex, offsetBy: index + 4)
        let sub = hexaString.substring(with: range)
        
        let char = Character(UnicodeScalar(Int(strtoul(sub, nil, 16)))!)
        return "\(char)"
    }
    
    open func addCodeUnescapingParsingWithFormattingBlock(_ formattingBlock: @escaping LTMarkdownParserFormattingBlock) {
        addMonospacedParsingWithFormattingBlock { attributedString, range in
            let matchString = attributedString.attributedSubstring(from: range).string
            var unescapedString = ""
            for index in 0..<range.length {
                guard index * 4 < range.length else { break }
                
                unescapedString = "\(unescapedString)\(LTMarkdownParser.stringWithHexaString(matchString, atIndex: index * 4))"
            }
            attributedString.replaceCharacters(in: range, with: unescapedString)
            formattingBlock(attributedString, NSRange(location: range.location, length: (unescapedString as NSString).length))
        }
    }
    
    open func addUnescapingParsing() {
        guard let unescapingRegex = TSSwiftMarkdownRegex.regexForString(TSSwiftMarkdownRegex.Unescaping, options: .dotMatchesLineSeparators) else { return }
        
        addParsingRuleWithRegularExpression(unescapingRegex) { match, attributedString in
            let range = NSRange(location: match.range.location + 1, length: 4)
            let matchString = attributedString.attributedSubstring(from: range).string
            let unescapedString = LTMarkdownParser.stringWithHexaString(matchString, atIndex: 0)
            attributedString.replaceCharacters(in: match.range, with: unescapedString)
        }
    }
    
}
