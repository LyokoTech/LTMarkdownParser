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
    
    public static func regexForString(regexString: String, options: NSRegularExpressionOptions = []) -> NSRegularExpression? {
        do {
            return try NSRegularExpression(pattern: regexString, options: options)
        } catch {
            return nil
        }
    }
}

public class LTMarkdownParser: TSBaseParser {
    
    public typealias LTMarkdownParserFormattingBlock = ((NSMutableAttributedString, NSRange) -> Void)
    public typealias LTMarkdownParserLevelFormattingBlock = ((NSMutableAttributedString, NSRange, Int) -> Void)
    
    public var headerAttributes = [[String: AnyObject]]()
    public var listAttributes = [[String: AnyObject]]()
    public var numberedListAttributes = [[String: AnyObject]]()
    public var quoteAttributes = [[String: AnyObject]]()
    
    public var imageAttributes = [String: AnyObject]()
    public var linkAttributes = [String: AnyObject]()
    public var monospaceAttributes = [String: AnyObject]()
    public var strongAttributes = [String: AnyObject]()
    public var emphasisAttributes = [String: AnyObject]()
    public var strongAndEmphasisAttributes = [String: AnyObject]()
    
    public static var standardParser = LTMarkdownParser()
    
    class func addAttributes(attributesArray: [[String: AnyObject]], atIndex level: Int, toString attributedString: NSMutableAttributedString, range: NSRange) {
        guard !attributesArray.isEmpty else { return }
        
        guard let newAttributes = level < attributesArray.count && level >= 0 ? attributesArray[level] : attributesArray.last else { return }
        
        attributedString.addAttributes(newAttributes, range: range)
    }
    
    public init(withDefaultParsing: Bool = true) {
        super.init()
        
        defaultAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(12)]
        headerAttributes = [
            [NSFontAttributeName: UIFont.boldSystemFontOfSize(23)],
            [NSFontAttributeName: UIFont.boldSystemFontOfSize(21)],
            [NSFontAttributeName: UIFont.boldSystemFontOfSize(19)],
            [NSFontAttributeName: UIFont.boldSystemFontOfSize(17)],
            [NSFontAttributeName: UIFont.boldSystemFontOfSize(15)],
            [NSFontAttributeName: UIFont.boldSystemFontOfSize(13)]
        ]
        
        linkAttributes = [
            NSForegroundColorAttributeName: UIColor.blueColor(),
            NSUnderlineColorAttributeName: NSUnderlineStyle.StyleSingle.rawValue
        ]
        
        monospaceAttributes = [
            NSFontAttributeName: UIFont(name: "Menlo", size: 12) ?? UIFont.systemFontOfSize(12),
            NSForegroundColorAttributeName: UIColor(red: 0.95, green: 0.54, blue: 0.55, alpha: 1)
        ]
        
        strongAttributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(12)]
        emphasisAttributes = [NSFontAttributeName: UIFont.italicSystemFontOfSize(12)]
        
        var strongAndEmphasisFont = UIFont.systemFontOfSize(12)
        strongAndEmphasisFont = UIFont(descriptor: strongAndEmphasisFont.fontDescriptor().fontDescriptorWithSymbolicTraits([.TraitItalic, .TraitBold]), size: strongAndEmphasisFont.pointSize)
        strongAndEmphasisAttributes = [NSFontAttributeName: strongAndEmphasisFont]
        
        if withDefaultParsing {
            addNumberedListParsingWithLeadFormattingBlock({ (attributedString, range, level) in
                let substring = attributedString.attributedSubstringFromRange(range).string.stringByReplacingOccurrencesOfString(" ", withString: "\(nonBreakingSpaceCharacter)")
                attributedString.replaceCharactersInRange(range, withString: "\(substring)")
            }, textFormattingBlock: { attributedString, range, level in
                LTMarkdownParser.addAttributes(self.numberedListAttributes, atIndex: level - 1, toString: attributedString, range: range)
            })
            
            addEscapingParsing()
            addCodeEscapingParsing()
            
            addHeaderParsingWithLeadFormattingBlock({ attributedString, range, level in
                attributedString.replaceCharactersInRange(range, withString: "")
            }, textFormattingBlock: { attributedString, range, level in
                LTMarkdownParser.addAttributes(self.headerAttributes, atIndex: level - 1, toString: attributedString, range: range)
            })
            
            addListParsingWithLeadFormattingBlock({ attributedString, range, level in
                let indentString = String(count: level, repeatedValue: nonBreakingSpaceCharacter)
                attributedString.replaceCharactersInRange(range, withString: "\(indentString)\u{2022}\u{00A0}")
            }, textFormattingBlock: { attributedString, range, level in
                LTMarkdownParser.addAttributes(self.listAttributes, atIndex: level - 1, toString: attributedString, range: range)
            })
            
            addQuoteParsingWithLeadFormattingBlock({ attributedString, range, level in
                let indentString = String(count: level, repeatedValue: Character("\t"))
                attributedString.replaceCharactersInRange(range, withString: indentString)
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
                attributedString.enumerateAttributesInRange(range, options: []) { attributes, range, _ in
                    if let font = attributes[NSFontAttributeName] as? UIFont, italicFont = self.emphasisAttributes[NSFontAttributeName] as? UIFont where font == italicFont {
                        attributedString.addAttributes(self.strongAndEmphasisAttributes, range: range)
                    } else {
                        attributedString.addAttributes(self.strongAttributes, range: range)
                    }
                }
            }
            
            addEmphasisParsingWithFormattingBlock { attributedString, range in
                attributedString.enumerateAttributesInRange(range, options: []) { attributes, range, _ in
                    if let font = attributes[NSFontAttributeName] as? UIFont, boldFont = self.strongAttributes[NSFontAttributeName] as? UIFont where font == boldFont {
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
    
    public func addEscapingParsing() {
        guard let escapingRegex = TSSwiftMarkdownRegex.regexForString(TSSwiftMarkdownRegex.Escaping) else { return }
        
        addParsingRuleWithRegularExpression(escapingRegex) { match, attributedString in
            let range = NSRange(location: match.range.location + 1, length: 1)
            let matchString = attributedString.attributedSubstringFromRange(range).string as NSString
            let escapedString = NSString(format: "%04x", matchString.characterAtIndex(0)) as String
            attributedString.replaceCharactersInRange(range, withString: escapedString)
        }
    }
    
    public func addCodeEscapingParsing() {
        guard let codingParsingRegex = TSSwiftMarkdownRegex.regexForString(TSSwiftMarkdownRegex.Monospace) else { return }
        
        addParsingRuleWithRegularExpression(codingParsingRegex) { match, attributedString in
            let range = match.rangeAtIndex(2)
            let matchString = attributedString.attributedSubstringFromRange(range).string as NSString
            
            var escapedString = ""
            for index in 0..<range.length {
                escapedString = "\(escapedString)\(NSString(format: "%04x", matchString.characterAtIndex(index)))"
            }

            attributedString.replaceCharactersInRange(range, withString: escapedString)
        }
    }
    
    private func addLeadParsingWithPattern(pattern: String, maxLevel: Int?, leadFormattingBlock: LTMarkdownParserLevelFormattingBlock, formattingBlock: LTMarkdownParserLevelFormattingBlock?) {
        let regexString: String = {
            let maxLevel: Int = maxLevel ?? 0
            return NSString(format: pattern, maxLevel > 0 ? "\(maxLevel)" : "") as String
        }()
        
        guard let regex = TSSwiftMarkdownRegex.regexForString(regexString, options: .AnchorsMatchLines) else { return }
        
        addParsingRuleWithRegularExpression(regex) { match, attributedString in
            let level = match.rangeAtIndex(1).length
            formattingBlock?(attributedString, match.rangeAtIndex(2), level)
            leadFormattingBlock(attributedString, NSRange(location: match.rangeAtIndex(1).location, length: match.rangeAtIndex(2).location - match.rangeAtIndex(1).location), level)
        }
    }
    
    public func addHeaderParsingWithLeadFormattingBlock(leadFormattingBlock: LTMarkdownParserLevelFormattingBlock, maxLevel: Int? = nil, textFormattingBlock formattingBlock: LTMarkdownParserLevelFormattingBlock?) {
        addLeadParsingWithPattern(TSSwiftMarkdownRegex.Header, maxLevel: maxLevel, leadFormattingBlock: leadFormattingBlock, formattingBlock: formattingBlock)
    }
    
    public func addListParsingWithLeadFormattingBlock(leadFormattingBlock: LTMarkdownParserLevelFormattingBlock, maxLevel: Int? = nil, textFormattingBlock formattingBlock: LTMarkdownParserLevelFormattingBlock?) {
        addLeadParsingWithPattern(TSSwiftMarkdownRegex.List, maxLevel: maxLevel, leadFormattingBlock: leadFormattingBlock, formattingBlock: formattingBlock)
    }
    
    public func addNumberedListParsingWithLeadFormattingBlock(leadFormattingBlock: LTMarkdownParserLevelFormattingBlock, maxLevel: Int? = nil, textFormattingBlock formattingBlock: LTMarkdownParserLevelFormattingBlock?) {
        addLeadParsingWithPattern(TSSwiftMarkdownRegex.NumberedList, maxLevel: maxLevel, leadFormattingBlock: leadFormattingBlock, formattingBlock: formattingBlock)
    }
    
    public func addQuoteParsingWithLeadFormattingBlock(leadFormattingBlock: LTMarkdownParserLevelFormattingBlock, maxLevel: Int? = nil, textFormattingBlock formattingBlock: LTMarkdownParserLevelFormattingBlock?) {
        addLeadParsingWithPattern(TSSwiftMarkdownRegex.Quote, maxLevel: maxLevel, leadFormattingBlock: leadFormattingBlock, formattingBlock: formattingBlock)
    }
    
    public func addShortHeaderParsingWithLeadFormattingBlock(leadFormattingBlock: LTMarkdownParserLevelFormattingBlock, maxLevel: Int? = nil, textFormattingBlock formattingBlock: LTMarkdownParserLevelFormattingBlock?) {
        addLeadParsingWithPattern(TSSwiftMarkdownRegex.ShortHeader, maxLevel: maxLevel, leadFormattingBlock: leadFormattingBlock, formattingBlock: formattingBlock)
    }
    
    public func addShortListParsingWithLeadFormattingBlock(leadFormattingBlock: LTMarkdownParserLevelFormattingBlock, maxLevel: Int? = nil, textFormattingBlock formattingBlock: LTMarkdownParserLevelFormattingBlock?) {
        addLeadParsingWithPattern(TSSwiftMarkdownRegex.ShortList, maxLevel: maxLevel, leadFormattingBlock: leadFormattingBlock, formattingBlock: formattingBlock)
    }
    
    public func addShortQuoteParsingWithLeadFormattingBlock(leadFormattingBlock: LTMarkdownParserLevelFormattingBlock, maxLevel: Int? = nil, textFormattingBlock formattingBlock: LTMarkdownParserLevelFormattingBlock?) {
        addLeadParsingWithPattern(TSSwiftMarkdownRegex.ShortQuote, maxLevel: maxLevel, leadFormattingBlock: leadFormattingBlock, formattingBlock: formattingBlock)
    }
    
    public func addImageParsingWithImageFormattingBlock(formattingBlock: LTMarkdownParserFormattingBlock?, alternativeTextFormattingBlock alternateFormattingBlock: LTMarkdownParserFormattingBlock?) {
        guard let headerRegex = TSSwiftMarkdownRegex.regexForString(TSSwiftMarkdownRegex.Image, options: .DotMatchesLineSeparators) else { return }
        
        addParsingRuleWithRegularExpression(headerRegex) { match, attributedString in
            let imagePathStart = (attributedString.string as NSString).rangeOfString("(", options: [], range: match.range).location
            let linkRange = NSRange(location: imagePathStart, length: match.range.length + match.range.location - imagePathStart - 1)
            let imagePath = (attributedString.string as NSString).substringWithRange(NSRange(location: linkRange.location + 1, length: linkRange.length - 1))
            
            if let image = UIImage(named: imagePath) {
                let imageAttatchment = NSTextAttachment()
                imageAttatchment.image = image
                imageAttatchment.bounds = CGRect(x: 0, y: -5, width: image.size.width, height: image.size.height)
                let imageString = NSAttributedString(attachment: imageAttatchment)
                attributedString.replaceCharactersInRange(match.range, withAttributedString: imageString)
                formattingBlock?(attributedString, NSRange(location: match.range.location, length: imageString.length))
            } else {
                let linkTextEndLocation = (attributedString.string as NSString).rangeOfString("]", options: [], range: match.range).location
                let linkTextRange = NSRange(location: match.range.location + 2, length: linkTextEndLocation - match.range.location - 2)
                let alternativeText = (attributedString.string as NSString).substringWithRange(linkTextRange)
                attributedString.replaceCharactersInRange(match.range, withString: alternativeText)
                alternateFormattingBlock?(attributedString, NSRange(location: match.range.location, length: (alternativeText as NSString).length))
            }
        }
    }
    
    public func addLinkParsingWithFormattingBlock(formattingBlock: LTMarkdownParserFormattingBlock) {
        guard let linkRegex = TSSwiftMarkdownRegex.regexForString(TSSwiftMarkdownRegex.Link, options: .DotMatchesLineSeparators) else { return }
        
        addParsingRuleWithRegularExpression(linkRegex) { match, attributedString in
            let linkStartinResult = (attributedString.string as NSString).rangeOfString("(", options: .BackwardsSearch, range: match.range).location
            let linkRange = NSRange(location: linkStartinResult, length: match.range.length + match.range.location - linkStartinResult - 1)
            let linkURLString = (attributedString.string as NSString).substringWithRange(NSRange(location: linkRange.location + 1, length: linkRange.length - 1))
            
            let linkTextRange = NSRange(location: match.range.location + 1, length: linkStartinResult - match.range.location - 2)
            attributedString.deleteCharactersInRange(NSRange(location: linkRange.location - 1, length: linkRange.length + 2))
            
            let urlCharacterSet: NSMutableCharacterSet = NSMutableCharacterSet(charactersInString: "")
            urlCharacterSet.formUnionWithCharacterSet(NSCharacterSet.URLPathAllowedCharacterSet())
            urlCharacterSet.formUnionWithCharacterSet(NSCharacterSet.URLPathAllowedCharacterSet())
            urlCharacterSet.formUnionWithCharacterSet(NSCharacterSet.URLQueryAllowedCharacterSet())
            urlCharacterSet.formUnionWithCharacterSet(NSCharacterSet.URLFragmentAllowedCharacterSet())

            
            
            if let URL = NSURL(string: linkURLString) ?? NSURL(string: linkURLString.stringByAddingPercentEncodingWithAllowedCharacters(urlCharacterSet) ?? linkURLString) {
                attributedString.addAttribute(NSLinkAttributeName, value: URL, range: linkTextRange)
            }
            formattingBlock(attributedString, linkTextRange)
            
            attributedString.deleteCharactersInRange(NSRange(location: match.range.location, length: 1))
        }
    }
    
    private func addEnclosedParsingWithPattern(pattern: String, formattingBlock: LTMarkdownParserFormattingBlock) {
        guard let regex = TSSwiftMarkdownRegex.regexForString(pattern) else { return }
        
        addParsingRuleWithRegularExpression(regex) { match, attributedString in
            attributedString.deleteCharactersInRange(match.rangeAtIndex(3))
            formattingBlock(attributedString, match.rangeAtIndex(2))
            attributedString.deleteCharactersInRange(match.rangeAtIndex(1))
        }
    }
    
    public func addMonospacedParsingWithFormattingBlock(formattingBlock: LTMarkdownParserFormattingBlock) {
        addEnclosedParsingWithPattern(TSSwiftMarkdownRegex.Monospace, formattingBlock: formattingBlock)
    }
    
    public func addStrongParsingWithFormattingBlock(formattingBlock: LTMarkdownParserFormattingBlock) {
        addEnclosedParsingWithPattern(TSSwiftMarkdownRegex.Strong, formattingBlock: formattingBlock)
    }
    
    public func addEmphasisParsingWithFormattingBlock(formattingBlock: LTMarkdownParserFormattingBlock) {
        addEnclosedParsingWithPattern(TSSwiftMarkdownRegex.Emphasis, formattingBlock: formattingBlock)
    }
    
    public func addStrongAndEmphasisParsingWithFormattingBlock(formattingBlock: LTMarkdownParserFormattingBlock) {
        addEnclosedParsingWithPattern(TSSwiftMarkdownRegex.StrongAndEmphasis, formattingBlock: formattingBlock)
    }
    
    public func addLinkDetectionWithFormattingBlock(formattingBlock: LTMarkdownParserFormattingBlock) {
        do {
            let linkDataDetector = try NSDataDetector(types: NSTextCheckingType.Link.rawValue)
            addParsingRuleWithRegularExpression(linkDataDetector) { match, attributedString in
                let linkURLString = (attributedString.string as NSString).substringWithRange(match.range)
                if let URL = NSURL(string: linkURLString) {
                    attributedString.addAttribute(NSLinkAttributeName, value: URL, range: match.range)
                }
                formattingBlock(attributedString, match.range)
            }
        } catch { }
    }
    
    private class func stringWithHexaString(hexaString: String, atIndex index: Int) -> String {
        let range = hexaString.startIndex.advancedBy(index)..<hexaString.startIndex.advancedBy(index + 4)
        let sub = hexaString.substringWithRange(range)
        
        let char = Character(UnicodeScalar(Int(strtoul(sub, nil, 16))))
        return "\(char)"
    }
    
    public func addCodeUnescapingParsingWithFormattingBlock(formattingBlock: LTMarkdownParserFormattingBlock) {
        addMonospacedParsingWithFormattingBlock { attributedString, range in
            let matchString = attributedString.attributedSubstringFromRange(range).string
            var unescapedString = ""
            for index in 0..<range.length {
                guard index * 4 < range.length else { break }
                
                unescapedString = "\(unescapedString)\(LTMarkdownParser.stringWithHexaString(matchString, atIndex: index * 4))"
            }
            attributedString.replaceCharactersInRange(range, withString: unescapedString)
            formattingBlock(attributedString, NSRange(location: range.location, length: (unescapedString as NSString).length))
        }
    }
    
    public func addUnescapingParsing() {
        guard let unescapingRegex = TSSwiftMarkdownRegex.regexForString(TSSwiftMarkdownRegex.Unescaping, options: .DotMatchesLineSeparators) else { return }
        
        addParsingRuleWithRegularExpression(unescapingRegex) { match, attributedString in
            let range = NSRange(location: match.range.location + 1, length: 4)
            let matchString = attributedString.attributedSubstringFromRange(range).string
            let unescapedString = LTMarkdownParser.stringWithHexaString(matchString, atIndex: 0)
            attributedString.replaceCharactersInRange(match.range, withString: unescapedString)
        }
    }
    
}
