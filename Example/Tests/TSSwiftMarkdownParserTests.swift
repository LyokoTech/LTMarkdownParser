//
//  TSSwiftMarkdownParserTests.swift
//  TSSwiftMarkdownParser
//
//  Created by Rhett Rogers on 3/25/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import UIKit
import TSSwiftMarkdownParser

class TSSwiftMarkdownParserTests: XCTestCase {
    
    var parser = TSSwiftMarkdownParser(withDefaultParsing: false)
    var standardParser = TSSwiftMarkdownParser()
    
    override func setUp() {
        parser = TSSwiftMarkdownParser(withDefaultParsing: false)
        standardParser = TSSwiftMarkdownParser()
    }
    
    func testBasicBoldParsing() {
        let font = UIFont(name: "HelveticaNeue-Bold", size: 14) ?? UIFont.systemFontOfSize(14)
        
        guard let boldRegex = TSSwiftMarkdownRegex.regexForString("\\*{2}.*\\*{2}", options: .CaseInsensitive) else {
            XCTAssert(false)
            return
        }
        
        parser.addParsingRuleWithRegularExpression(boldRegex) { match, attributedString in
            attributedString.addAttribute(NSFontAttributeName, value: font, range: match.range)
            attributedString.deleteCharactersInRange(NSRange(location: match.range.location, length: 2))
            attributedString.deleteCharactersInRange(NSRange(location: match.range.location + match.range.length - 4, length: 2))
        }
        
        let attributedString = parser.attributedStringFromMarkdown("Hello\nI go to **café** everyday")
        XCTAssertEqual(attributedString?.attribute(NSFontAttributeName, atIndex: 15, effectiveRange: nil) as? UIFont, font)
        XCTAssertEqual(attributedString?.string.rangeOfString("*"), nil)
        
    }
    
    func testBasicEmphasisParsing() {
        let font = UIFont.italicSystemFontOfSize(12)
        
        guard let italicRegex = TSSwiftMarkdownRegex.regexForString("\\*{1}.*\\*{1}", options: .CaseInsensitive) else {
            XCTAssert(false)
            return
        }
        
        parser.addParsingRuleWithRegularExpression(italicRegex) { match, attributedString in
            attributedString.addAttribute(NSFontAttributeName, value: font, range: match.range)
            attributedString.deleteCharactersInRange(NSRange(location: match.range.location, length: 1))
            attributedString.deleteCharactersInRange(NSRange(location: match.range.location + match.range.length - 2, length: 1))
        }
        
        let attributedString = parser.attributedStringFromMarkdown("Hello\nI go to *café* everyday")
        XCTAssertEqual(attributedString?.attribute(NSFontAttributeName, atIndex: 15, effectiveRange: nil) as? UIFont, font)
        XCTAssertEqual(attributedString?.string.rangeOfString("*"), nil)
        
    }
    
    func testStandardFont() {
        let font = UIFont.systemFontOfSize(12)
        XCTAssertEqual(parser.defaultAttributes[NSFontAttributeName] as? UIFont, font)
    }
    
    func testBoldFont() {
        let font = UIFont.boldSystemFontOfSize(12)
        XCTAssertEqual(parser.strongAttributes[NSFontAttributeName] as? UIFont, font)
    }
    
    func testItalicFont() {
        let font = UIFont.italicSystemFontOfSize(12)
        XCTAssertEqual(parser.emphasisAttributes[NSFontAttributeName] as? UIFont, font)
    }
    
    func testDefaultBoldParsing() {
        let font = UIFont.boldSystemFontOfSize(12)
        let attributedString = standardParser.attributedStringFromMarkdown("Hello\nI drink in **a café** everyday")
        XCTAssertEqual(attributedString?.attribute(NSFontAttributeName, atIndex: 20, effectiveRange: nil) as? UIFont, font)
        XCTAssertEqual(attributedString?.string, "Hello\nI drink in a café everyday")
    }
    
    func testDefaultEmphasisParsing() {
        let font = UIFont.italicSystemFontOfSize(12)
        let attributedString = standardParser.attributedStringFromMarkdown("Hello\nI drink in *a café* everyday")
        XCTAssertEqual(attributedString?.attribute(NSFontAttributeName, atIndex: 20, effectiveRange: nil) as? UIFont, font)
        XCTAssertEqual(attributedString?.string, "Hello\nI drink in a café everyday")
    }
    
    func testDefaultBoldParsingUnderscores() {
        let font = UIFont.boldSystemFontOfSize(12)
        let attributedString = standardParser.attributedStringFromMarkdown("Hello\nI drink in __a café__ everyday")

        XCTAssertEqual(attributedString?.attribute(NSFontAttributeName, atIndex: 20, effectiveRange: nil) as? UIFont, font)
        XCTAssertEqual(attributedString?.string, "Hello\nI drink in a café everyday")
    }
    
    func testDefaultEmphasisParsingUnderscores() {
        let font = UIFont.italicSystemFontOfSize(12)
        let attributedString = standardParser.attributedStringFromMarkdown("Hello\nI drink in _a café_ everyday")
        XCTAssertEqual(attributedString?.attribute(NSFontAttributeName, atIndex: 20, effectiveRange: nil) as? UIFont, font)
        XCTAssertEqual(attributedString?.string, "Hello\nI drink in a café everyday")
    }
    
    func testDefaultMonospaceParsing() {
        let font = standardParser.monospaceAttributes[NSFontAttributeName] as? UIFont
        let attributedString = standardParser.attributedStringFromMarkdown("Hello\nI drink in `a café` everyday")
        XCTAssertEqual(attributedString?.attribute(NSFontAttributeName, atIndex: 20, effectiveRange: nil) as? UIFont, font)
        XCTAssertEqual(attributedString?.string, "Hello\nI drink in a café everyday")
    }
    
    func testDefaultBoldParsingOneCharacter() {
        let font = self.standardParser.strongAttributes[NSFontAttributeName] as? UIFont
        let attributedString = standardParser.attributedStringFromMarkdown("This is **a** nice **boy**")
        XCTAssertNotEqual(attributedString?.attribute(NSFontAttributeName, atIndex: 9, effectiveRange: nil) as? UIFont, font)
    }
    
    func testDefaultEmphasisParsingOneCharacter() {
        let font = self.standardParser.emphasisAttributes[NSFontAttributeName] as? UIFont
        let attributedString = standardParser.attributedStringFromMarkdown("This is *a* nice *boy*")
        XCTAssertNotEqual(attributedString?.attribute(NSFontAttributeName, atIndex: 9, effectiveRange: nil) as? UIFont, font)
    }
    
    func testDefaultMonospaceParsingOneCharacter() {
        let font = self.standardParser.monospaceAttributes[NSFontAttributeName] as? UIFont
        let attributedString = standardParser.attributedStringFromMarkdown("This is `a` nice `boy`")
        XCTAssertNotEqual(attributedString?.attribute(NSFontAttributeName, atIndex: 9, effectiveRange: nil) as? UIFont, font)
    }
    
    func testDefaultStrongAndEmphasisAndMonospaceInSameInputParsing() {
        let fonts = (
            strong: parser.strongAttributes[NSFontAttributeName] as? UIFont,
            emphasis: parser.emphasisAttributes[NSFontAttributeName] as? UIFont,
            monospace: parser.monospaceAttributes[NSFontAttributeName] as? UIFont
        )
        
        var snippets = (
            strong: ["Tennis Court", "Strawberries and Cream", "Worn Grass"],
            emphasis: ["under", "From", "progress"],
            monospace: ["tournament", "seat"]
        )
        
        var actualNumberOfBlocks = (
            strong: 0,
            emphasis: 0,
            monospace: 0
        )
        
        let expectedNumberOfBlocks = (
            strong: snippets.strong.count,
            emphasis: snippets.emphasis.count,
            monospace: snippets.monospace.count
        )
        
        func increaseCountAndRemoveSnippet(inout count: Int, snippet: String, inout snippets: [String]) {
            count += 1
            
            if let index = snippets.indexOf(snippet) {
                snippets.removeAtIndex(index)
            }
        }
        
        let attributedString = standardParser.attributedStringFromMarkdown("**Tennis Court** Stand *under* the spectacular glass-and-steel roof.\n\n__Strawberries and Cream__ _From_ your `seat`.\n\n**Worn Grass** See the *progress* of the `tournament`.")
        
        attributedString?.enumerateAttributesInRange(NSRange(location: 0, length: attributedString!.length), options: .LongestEffectiveRangeNotRequired) { attributes, range, stop in
            let font = attributes[NSFontAttributeName] as? UIFont
            let snippet = (attributedString!.string as NSString).substringWithRange(range)
            
            if fonts.emphasis == font {
                increaseCountAndRemoveSnippet(&actualNumberOfBlocks.emphasis, snippet: snippet, snippets: &snippets.emphasis)
            } else if fonts.strong == font {
                increaseCountAndRemoveSnippet(&actualNumberOfBlocks.strong, snippet: snippet, snippets: &snippets.strong)
            } else if fonts.monospace == font {
                increaseCountAndRemoveSnippet(&actualNumberOfBlocks.monospace, snippet: snippet, snippets: &snippets.monospace)
            }
        }
        
        XCTAssertEqual(actualNumberOfBlocks.emphasis, expectedNumberOfBlocks.emphasis)
        XCTAssertEqual(snippets.emphasis.count, 0)
        XCTAssertEqual(actualNumberOfBlocks.strong, expectedNumberOfBlocks.strong)
        XCTAssertEqual(snippets.strong.count, 0)
        XCTAssertEqual(actualNumberOfBlocks.monospace, expectedNumberOfBlocks.monospace)
        XCTAssertEqual(snippets.monospace.count, 0)
    }
    
    func testDefaultListWithAsteriskParsing() {
        let attributedString = standardParser.attributedStringFromMarkdown("Hello\n* I drink in a café everyday\nto use Wi-Fi")
        XCTAssertEqual(attributedString!.string, "Hello\n•\u{00A0}I drink in a café everyday\nto use Wi-Fi")
    }
    
    func testDefaultQuoteParsing() {
        let attributedString = standardParser.attributedStringFromMarkdown("Hello\n> I drink in a café everyday\nto use Wi-Fi")
        XCTAssertEqual(attributedString!.string, "Hello\n\tI drink in a café everyday\nto use Wi-Fi")
    }
    
    func testDefaultQuoteLevel2Parsing() {
        let attributedString = standardParser.attributedStringFromMarkdown("Hello\n>> I drink in a café everyday\nto use Wi-Fi")
        XCTAssertEqual(attributedString!.string, "Hello\n\t\tI drink in a café everyday\nto use Wi-Fi")
    }
    
    func testDefaultListWithAsteriskParsingMultiple() {
        let attributedString = standardParser.attributedStringFromMarkdown("Hello\n* I drink in a café everyday\n* to use Wi-Fi")
        XCTAssertEqual(attributedString!.string, "Hello\n•\u{00A0}I drink in a café everyday\n•\u{00A0}to use Wi-Fi")
    }
    
    func testCustomListWithAsterisksParsingWithStrongText() {
        let strongFont = UIFont.boldSystemFontOfSize(12)
        parser.addListParsingWithLeadFormattingBlock({ attributedString, range, level in
            attributedString.replaceCharactersInRange(range, withString: "    • ")
        }, maxLevel: 1, textFormattingBlock: nil)
        
        parser.addStrongParsingWithFormattingBlock { attributedString, range in
            attributedString.addAttribute(NSFontAttributeName, value: strongFont, range: range)
        }
        
        let expectedNumberOfStrongBlocks = 1
        var actualNumberOfStrongBlocks = 0
        var strongSnippets = ["Strong Text:"]
        
        let expectedRawString = "Strong Text: Some Subtitle.\n\n    • List Item One\n    • List Item Two"
        let attributedString = parser.attributedStringFromMarkdown("**Strong Text:** Some Subtitle.\n\n* List Item One\n* List Item Two")
        attributedString?.enumerateAttributesInRange(NSRange(location: 0, length: (attributedString?.length)!), options: .LongestEffectiveRangeNotRequired) { attributes, range, stop in
            let font = attributes[NSFontAttributeName] as? UIFont
            if strongFont == font {
                actualNumberOfStrongBlocks += 1
                let snippet = (attributedString!.string as NSString).substringWithRange(range)
                if let index = strongSnippets.indexOf(snippet) {
                    strongSnippets.removeAtIndex(index)
                }
            }
        }
        
        XCTAssertEqual(actualNumberOfStrongBlocks, expectedNumberOfStrongBlocks)
        XCTAssertEqual(strongSnippets.count, 0)
        XCTAssertEqual(attributedString?.string, expectedRawString)
    }
    
    func testDefaultListWithPlusParsing() {
        let attributedString = standardParser.attributedStringFromMarkdown("Hello\n+ I drink in a café everyday\nto use Wi-Fi")
        XCTAssertEqual(attributedString!.string, "Hello\n•\u{00A0}I drink in a café everyday\nto use Wi-Fi")
    }
    
    func testDefaultListWithDashParsing() {
        let attributedString = standardParser.attributedStringFromMarkdown("Hello\n- I drink in a café everyday\nto use Wi-Fi")
        XCTAssertEqual(attributedString!.string, "Hello\n•\u{00A0}I drink in a café everyday\nto use Wi-Fi")
    }
    
    func testDefaultListWithPlusParsingMultiple() {
        let attributedString = standardParser.attributedStringFromMarkdown("Hello\n+ I drink in a café everyday\n+ to use Wi-Fi")
        XCTAssertEqual(attributedString!.string, "Hello\n•\u{00A0}I drink in a café everyday\n•\u{00A0}to use Wi-Fi")
    }
    
    func testThatDefaultListWorksWithMultipleDifferentListOptions() {
        let attributedString = standardParser.attributedStringFromMarkdown("Hello\n+ item1\n- item2\n* item3")
        XCTAssertEqual(attributedString!.string, "Hello\n•\u{00A0}item1\n•\u{00A0}item2\n•\u{00A0}item3")
    }
    
    func testDefaultLinkParsing() {
        let attributedString = standardParser.attributedStringFromMarkdown("Hello\n This is a [link](https://www.example.net/) to test Wi-Fi\nat home")
        let link = attributedString?.attribute(NSLinkAttributeName, atIndex:20, effectiveRange:nil) as? NSURL
        XCTAssertEqual(link, NSURL(string: "https://www.example.net/"))
        XCTAssertNil(attributedString?.string.rangeOfString("["))
        XCTAssertNil(attributedString?.string.rangeOfString("]"))
        XCTAssertNil(attributedString?.string.rangeOfString("("))
        XCTAssertNil(attributedString?.string.rangeOfString(")"))
        XCTAssertNotNil(attributedString?.string.rangeOfString("link"))
        let underline = attributedString?.attribute(NSUnderlineColorAttributeName, atIndex: 20, effectiveRange: nil)
        XCTAssertNotNil(underline)
        let linkColor = attributedString?.attribute(NSForegroundColorAttributeName, atIndex: 20, effectiveRange: nil) as! UIColor
        XCTAssertEqual(linkColor, UIColor.blueColor())
        
        let linkAtTheNextCharacter = attributedString?.attribute(NSLinkAttributeName, atIndex: 21, effectiveRange: nil)
        XCTAssertNil(linkAtTheNextCharacter);
    }
    
    func testDefaultAutoLinkParsing() {
        let attributedString = standardParser.attributedStringFromMarkdown("Hello\n This is a link https://www.example.net/ to test Wi-Fi\nat home")
        let link = attributedString?.attribute(NSLinkAttributeName, atIndex: 24, effectiveRange: nil) as! NSURL
        XCTAssertEqual(link, NSURL(string: "https://www.example.net/"))
        let underline = attributedString?.attribute(NSUnderlineColorAttributeName, atIndex: 24, effectiveRange: nil)
        XCTAssertNotNil(underline)
        let linkColor = attributedString?.attribute(NSForegroundColorAttributeName, atIndex: 24, effectiveRange: nil) as! UIColor
        XCTAssertEqual(linkColor, UIColor.blueColor())
    }
    
    func testDefaultLinkParsingOnEndOfStrings() {
        let attributedString = standardParser.attributedStringFromMarkdown("Hello\n This is a [link](https://www.example.net/)")
        let link = attributedString?.attribute(NSLinkAttributeName, atIndex:20, effectiveRange:nil) as? NSURL
        XCTAssertEqual(link, NSURL(string: "https://www.example.net/"))
        XCTAssertNil(attributedString?.string.rangeOfString("["))
        XCTAssertNil(attributedString?.string.rangeOfString("]"))
        XCTAssertNil(attributedString?.string.rangeOfString("("))
        XCTAssertNil(attributedString?.string.rangeOfString(")"))
        XCTAssertNotNil(attributedString?.string.rangeOfString("link"))
        let underline = attributedString?.attribute(NSUnderlineColorAttributeName, atIndex: 20, effectiveRange: nil)
        XCTAssertNotNil(underline)
        let linkColor = attributedString?.attribute(NSForegroundColorAttributeName, atIndex: 20, effectiveRange: nil) as! UIColor
        XCTAssertEqual(linkColor, UIColor.blueColor())
    }
    
    func testDefaultLinkParsingEnclosedInParenthesis() {
        let expectedRawString = "Hello\n This is a (link) to test Wi-Fi\nat home"
        let attributedString = standardParser.attributedStringFromMarkdown("Hello\n This is a ([link](https://www.example.net/)) to test Wi-Fi\nat home")
        let link = attributedString?.attribute(NSLinkAttributeName, atIndex: 21, effectiveRange: nil) as! NSURL
        XCTAssertEqual(link, NSURL(string: "https://www.example.net/"))
        XCTAssertEqual(attributedString!.string, expectedRawString)
    }
    
    func testDefaultLinkParsingWithBracketsInside() {
        let expectedRawString = "Hello\n a link [with brackets inside]"
        let attributedString = standardParser.attributedStringFromMarkdown("Hello\n [a link \\[with brackets inside]](https://example.net/)")
        let link = attributedString?.attribute(NSLinkAttributeName, atIndex: 35, effectiveRange: nil) as! NSURL
        XCTAssertEqual(link, NSURL(string: "https://example.net/"))
        XCTAssertEqual(attributedString!.string, expectedRawString)
    }
    
    func testDefaultLinkParsingWithBracketsOutside() {
        let expectedRawString = "Hello\n [This is not a link] but this is a link to test [the difference]"
        let attributedString = standardParser.attributedStringFromMarkdown("Hello\n [This is not a link] but this is a [link](https://www.example.net/) to test [the difference]")
        let link = attributedString?.attribute(NSLinkAttributeName, atIndex: 44, effectiveRange: nil) as! NSURL
        XCTAssertEqual(link, NSURL(string: "https://www.example.net/"))
        XCTAssertEqual(attributedString!.string, expectedRawString)
    }
    
    func testDefaultLinkParsingMultipleLinks() {
        let attributedString = standardParser.attributedStringFromMarkdown("Hello\n This is a [link](https://www.example.net/) and this is [a link](https://www.example.com/) too")
        
        let link = attributedString?.attribute(NSLinkAttributeName, atIndex: 17, effectiveRange: nil) as! NSURL
        let underline = attributedString?.attribute(NSUnderlineColorAttributeName, atIndex: 17, effectiveRange: nil)
        let linkColor = attributedString?.attribute(NSForegroundColorAttributeName, atIndex: 17, effectiveRange: nil) as! UIColor
        
        XCTAssertEqual(link, NSURL(string: "https://www.example.net/"))
        XCTAssertNotNil(underline)
        XCTAssertEqual(linkColor, UIColor.blueColor())
        
        let link2 = attributedString?.attribute(NSLinkAttributeName, atIndex: 37, effectiveRange: nil) as! NSURL
        let underline2 = attributedString?.attribute(NSUnderlineColorAttributeName, atIndex: 37, effectiveRange: nil)
        let linkColor2 = attributedString?.attribute(NSForegroundColorAttributeName, atIndex: 37, effectiveRange: nil) as! UIColor
        
        XCTAssertEqual(link2, NSURL(string: "https://www.example.com/"))
        XCTAssertNotNil(underline2)
        XCTAssertEqual(linkColor2, UIColor.blueColor())
    }
    
    func testDefaultLinkParsingWithPipe() {
        let expectedRawString = "Hello (link). Bye"
        let attributedString = standardParser.attributedStringFromMarkdown("Hello ([link](https://www.example.net/|)). Bye")
        let link = attributedString?.attribute(NSLinkAttributeName, atIndex: 8, effectiveRange: nil) as! NSURL
        XCTAssertEqual(link, NSURL(string: "https://www.example.net/|".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet(charactersInString: "htp://.wexamlns"))!))
        XCTAssertEqual(attributedString!.string, expectedRawString)
    }
    
    func testDefaultLinkParsingWithSharp() {
        let expectedRawString = "Hello (link). Bye"
        let attributedString = standardParser.attributedStringFromMarkdown("Hello ([link](https://www.example.net/#)). Bye")
        let link = attributedString?.attribute(NSLinkAttributeName, atIndex: 8, effectiveRange: nil) as! NSURL
        XCTAssertEqual(link, NSURL(string: "https://www.example.net/#"))
        XCTAssertEqual(attributedString!.string, expectedRawString)
    }
    
    func testDefaultFont() {
        let font = UIFont.systemFontOfSize(12)
        let attributedString = standardParser.attributedStringFromMarkdown("Hello\n Men att Pär är här\nmen inte Pia")
        XCTAssertEqual(attributedString?.attribute(NSFontAttributeName, atIndex: 6, effectiveRange: nil) as? UIFont, font)
    }
    
    func testDefaultH1() {
        let attributedString = standardParser.attributedStringFromMarkdown("Hello\n# Men att Pär är här\nmen inte Pia")
        let font = attributedString?.attribute(NSFontAttributeName, atIndex: 10, effectiveRange: nil) as? UIFont
        let expectedFont = standardParser.headerAttributes[0][NSFontAttributeName] as? UIFont
        XCTAssertNotNil(font);
        XCTAssertEqual(font, expectedFont);
        XCTAssertEqual(font?.pointSize, 23.0);
        XCTAssertNil(attributedString?.string.rangeOfString("#"))
        XCTAssertEqual(attributedString?.string, "Hello\nMen att Pär är här\nmen inte Pia")
    }
    
    func testThatH1IsParsedCorrectly() {
        let header = "header"
        let input = "first line\n# \(header)\nsecond line"
        let h1Font = standardParser.headerAttributes[0][NSFontAttributeName] as? UIFont
        let attributedString = standardParser.attributedStringFromMarkdown(input)
        let string = attributedString?.string
        let headerRange = string?.rangeOfString(header)
        XCTAssertNotNil(headerRange)
        attributedString?.enumerateAttributesInRange((string! as NSString).rangeOfString(header), options: .Reverse) { attributes, range, stop in
            let font = attributes[NSFontAttributeName] as? UIFont
            XCTAssertNotNil(font)
            XCTAssertEqual(font, h1Font)
        }
    }
    
    func testThatHeaderIsNotParsedWithoutSpaceInBetween() {
        let header = "header"
        let notValidHeader = "#\(header)"
        let h1Font = standardParser.headerAttributes[0][NSFontAttributeName] as? UIFont
        let attributedString = standardParser.attributedStringFromMarkdown(notValidHeader)
        let headerRange = (attributedString!.string as NSString).rangeOfString(header)
        attributedString?.enumerateAttributesInRange(headerRange, options: .Reverse) { attributes, range, stop in
            let font = attributes[NSFontAttributeName] as? UIFont
            XCTAssertNotEqual(font, h1Font)
        }
        XCTAssertEqual(attributedString?.string, notValidHeader)
    }
    
    func testThatHeaderIsNotParsedAtNotBeginningOfTheLine() {
        let hashtag = "#hashtag"
        let input = "A sentence \(hashtag)"
        let attributedString = standardParser.attributedStringFromMarkdown(input)
        XCTAssertEqual(attributedString?.string, input)
        let hashTagStillThereRange = attributedString?.string.rangeOfString(hashtag)
        XCTAssertNotNil(hashTagStillThereRange)
    }
    
    func testDefaultH2() {
        let attributedString = standardParser.attributedStringFromMarkdown("Hello\n## Men att Pär är här\nmen inte Pia")
        let font = attributedString?.attribute(NSFontAttributeName, atIndex: 10, effectiveRange: nil) as? UIFont
        let expectedFont = standardParser.headerAttributes[1][NSFontAttributeName] as? UIFont
        XCTAssertNotNil(font);
        XCTAssertEqual(font, expectedFont);
        XCTAssertNil(attributedString?.string.rangeOfString("#"))
        XCTAssertEqual(attributedString?.string, "Hello\nMen att Pär är här\nmen inte Pia")
    }
    
    func testDefaultH3() {
        let attributedString = standardParser.attributedStringFromMarkdown("Hello\n### Men att Pär är här\nmen inte Pia")
        let font = attributedString?.attribute(NSFontAttributeName, atIndex: 10, effectiveRange: nil) as? UIFont
        let expectedFont = standardParser.headerAttributes[2][NSFontAttributeName] as? UIFont
        XCTAssertNotNil(font);
        XCTAssertEqual(font, expectedFont);
        XCTAssertEqual(font?.pointSize, 19.0)
        XCTAssertNil(attributedString?.string.rangeOfString("#"))
        XCTAssertEqual(attributedString?.string, "Hello\nMen att Pär är här\nmen inte Pia")
    }
    
    func testDefaultH4() {
        let attributedString = standardParser.attributedStringFromMarkdown("Hello\n#### Men att Pär är här\nmen inte Pia")
        let font = attributedString?.attribute(NSFontAttributeName, atIndex: 10, effectiveRange: nil) as? UIFont
        let expectedFont = standardParser.headerAttributes[3][NSFontAttributeName] as? UIFont
        XCTAssertNotNil(font);
        XCTAssertEqual(font, expectedFont);
        XCTAssertEqual(font?.pointSize, 17.0)
        XCTAssertNil(attributedString?.string.rangeOfString("#"))
        XCTAssertEqual(attributedString?.string, "Hello\nMen att Pär är här\nmen inte Pia")
    }
    
    func testDefaultH5() {
        let attributedString = standardParser.attributedStringFromMarkdown("Hello\n##### Men att Pär är här\nmen inte Pia")
        let font = attributedString?.attribute(NSFontAttributeName, atIndex: 10, effectiveRange: nil) as? UIFont
        let expectedFont = standardParser.headerAttributes[4][NSFontAttributeName] as? UIFont
        XCTAssertNotNil(font);
        XCTAssertEqual(font, expectedFont);
        XCTAssertEqual(font?.pointSize, 15.0)
        XCTAssertNil(attributedString?.string.rangeOfString("#"))
        XCTAssertEqual(attributedString?.string, "Hello\nMen att Pär är här\nmen inte Pia")
    }
    
    func testDefaultH6() {
        let attributedString = standardParser.attributedStringFromMarkdown("Hello\n###### Men att Pär är här\nmen inte Pia")
        let font = attributedString?.attribute(NSFontAttributeName, atIndex: 10, effectiveRange: nil) as? UIFont
        let expectedFont = standardParser.headerAttributes[5][NSFontAttributeName] as? UIFont
        XCTAssertNotNil(font);
        XCTAssertEqual(font, expectedFont);
        XCTAssertEqual(font?.pointSize, 13.0)
        XCTAssertNil(attributedString?.string.rangeOfString("#"))
        XCTAssertEqual(attributedString?.string, "Hello\nMen att Pär är här\nmen inte Pia")
    }
    
    func testDefaultH6NextLine() {
        let attributedString = standardParser.attributedStringFromMarkdown("Hello\n###### Men att Pär är här\nmen inte Pia")
        let font = attributedString?.attribute(NSFontAttributeName, atIndex: 30, effectiveRange: nil) as? UIFont
        let expectedFont = UIFont.systemFontOfSize(12)
        XCTAssertNotNil(font);
        XCTAssertEqual(font, expectedFont);
        XCTAssertEqual(font?.pointSize, 12.0)
        XCTAssertEqual(attributedString?.string, "Hello\nMen att Pär är här\nmen inte Pia")
    }
    
    func testMultipleMatches() {
        let attributedString = standardParser.attributedStringFromMarkdown("## Hello\nMen att *Pär* är här\n+ men inte Pia")
        XCTAssertEqual(attributedString?.string, "Hello\nMen att Pär är här\n•\u{00A0}men inte Pia")
    }
    
    func testDefaultImage() {
        let attributedString = standardParser.attributedStringFromMarkdown("Men att ![Pär](markdown) är här\nmen inte Pia")
        let link = attributedString?.attribute(NSLinkAttributeName, atIndex: 8, effectiveRange: nil) as? String
        XCTAssertNil(link)
        let attachment = attributedString?.attribute(NSAttachmentAttributeName, atIndex: 8, effectiveRange: nil) as? NSTextAttachment
        XCTAssertNotNil(attachment)
        XCTAssertNotNil(attachment?.image)
        XCTAssertNil(attributedString?.string.rangeOfString("Pär"))
        XCTAssertNil(attributedString?.string.rangeOfString("!"))
        XCTAssertNil(attributedString?.string.rangeOfString("["))
        XCTAssertNil(attributedString?.string.rangeOfString("]"))
        XCTAssertNil(attributedString?.string.rangeOfString("("))
        XCTAssertNil(attributedString?.string.rangeOfString(")"))
        XCTAssertNil(attributedString?.string.rangeOfString("carrots"))
        
        let expected = "Men att \u{FFFC} är här\nmen inte Pia"
        XCTAssertEqual(attributedString?.string, expected)
    }
    
    func testDefaultImageWithUnderscores() {
        let attributedString = standardParser.attributedStringFromMarkdown("A ![AltText](markdown_test_image)")
        let link = attributedString?.attribute(NSLinkAttributeName, atIndex: 2, effectiveRange: nil) as? String
        XCTAssertNil(link)
        let attachment = attributedString?.attribute(NSAttachmentAttributeName, atIndex: 2, effectiveRange: nil) as? NSTextAttachment
        XCTAssertNotNil(attachment)
        XCTAssertNotNil(attachment?.image)
        XCTAssertNil(attributedString?.string.rangeOfString("AltText"))
        let expected = "A \u{FFFC}"
        XCTAssertEqual(attributedString?.string, expected)
    }
    
    func testDefaultImageMultiple() {
        let attributedString = standardParser.attributedStringFromMarkdown("Men att ![Pär](markdown) är här ![Pär](markdown)\nmen inte Pia")
        let link = attributedString?.attribute(NSLinkAttributeName, atIndex: 8, effectiveRange: nil) as? String
        XCTAssertNil(link)
        let attachment = attributedString?.attribute(NSAttachmentAttributeName, atIndex: 8, effectiveRange: nil) as? NSTextAttachment
        XCTAssertNotNil(attachment)
        XCTAssertNotNil(attachment?.image)
        XCTAssertNil(attributedString?.string.rangeOfString("Pär"))
        XCTAssertNil(attributedString?.string.rangeOfString("!"))
        XCTAssertNil(attributedString?.string.rangeOfString("["))
        XCTAssertNil(attributedString?.string.rangeOfString("]"))
        XCTAssertNil(attributedString?.string.rangeOfString("("))
        XCTAssertNil(attributedString?.string.rangeOfString(")"))
        XCTAssertNil(attributedString?.string.rangeOfString("carrots"))
        
        let expected = "Men att \u{FFFC} är här \u{FFFC}\nmen inte Pia"
        XCTAssertEqual(attributedString?.string, expected)
    }
    
    func testDefaultImageMissingImage() {
        let attributedString = standardParser.attributedStringFromMarkdown("Men att ![Pär](markdownas) är här\nmen inte Pia")
        let link = attributedString?.attribute(NSLinkAttributeName, atIndex: 8, effectiveRange: nil) as? String
        XCTAssertNil(link)
        let attachment = attributedString?.attribute(NSAttachmentAttributeName, atIndex: 8, effectiveRange: nil) as? NSTextAttachment
        XCTAssertNil(attachment)
        XCTAssertNotNil(attributedString?.string.rangeOfString("Pär"))
        XCTAssertNil(attributedString?.string.rangeOfString("!"))
        XCTAssertNil(attributedString?.string.rangeOfString("["))
        XCTAssertNil(attributedString?.string.rangeOfString("]"))
        XCTAssertNil(attributedString?.string.rangeOfString("("))
        XCTAssertNil(attributedString?.string.rangeOfString(")"))
        XCTAssertNil(attributedString?.string.rangeOfString("carrots"))
        
        let expected = "Men att Pär är här\nmen inte Pia"
        XCTAssertEqual(attributedString?.string, expected)
    }
    
    func testDefaultBoldParsingCustomFont() {
        let customFont = UIFont.boldSystemFontOfSize(19)
        standardParser.strongAttributes = [NSFontAttributeName: customFont]
        let attributedString = standardParser.attributedStringFromMarkdown("Hello\nMen att **Pär är här** men inte Pia")
        XCTAssertEqual((attributedString?.attribute(NSFontAttributeName, atIndex: 16, effectiveRange: nil) as? UIFont)!.pointSize, 19.0)
    }
    
    func testURLWithParenthesesInTheTitleText() {
        let attributedString = standardParser.attributedStringFromMarkdown("Hello\n Men att [Pär och (Mia)](https://www.example.net/) är här.")
        let link = attributedString?.attribute(NSLinkAttributeName, atIndex: 17, effectiveRange: nil) as? NSURL
        XCTAssertEqual(link, NSURL(string: "https://www.example.net/"))
        XCTAssertNotNil(attributedString?.string.rangeOfString("Pär"))
    }
    
    func testNestedBoldAndItalic() {
        // Test Still Needs to be written
        let attributedString = standardParser.attributedStringFromMarkdown("Hello **this string is bold _and italic_**")
        let boldFont = attributedString?.attribute(NSFontAttributeName, atIndex: 6, effectiveRange: nil) as? UIFont
        let boldItalicFont = attributedString?.attribute(NSFontAttributeName, atIndex: 26, effectiveRange: nil) as? UIFont
        
        let controlledBoldFont = standardParser.strongAttributes[NSFontAttributeName] as? UIFont
        let controlledBoldItalicFont = standardParser.strongAndEmphasisAttributes[NSFontAttributeName] as? UIFont
        
        XCTAssertEqual(boldFont, controlledBoldFont)
        XCTAssertEqual(boldItalicFont, controlledBoldItalicFont)
        XCTAssertEqual(attributedString?.string, "Hello this string is bold and italic")
    }
    
    func testNestedItalicAndBold() {
        let attributedString = standardParser.attributedStringFromMarkdown("Hello _this string is italic **and bold**_")
        let italicFont = attributedString?.attribute(NSFontAttributeName, atIndex: 6, effectiveRange: nil) as? UIFont
        let boldItalicFont = attributedString?.attribute(NSFontAttributeName, atIndex: 28, effectiveRange: nil) as? UIFont
        
        let controlledItalicFont = standardParser.emphasisAttributes[NSFontAttributeName] as? UIFont
        let controlledBoldItalicFont = standardParser.strongAndEmphasisAttributes[NSFontAttributeName] as? UIFont
        
        XCTAssertEqual(italicFont, controlledItalicFont)
        XCTAssertEqual(boldItalicFont, controlledBoldItalicFont)
        XCTAssertEqual(attributedString?.string, "Hello this string is italic and bold")
    }
    
    func testNumberedLists() {
        let markdownString = "1\\. Hi\n2\\. Hi\n3\\. Hi"
        let attributedString = standardParser.attributedStringFromMarkdown(markdownString)
        XCTAssertEqual(attributedString?.string, "1.\u{00A0}Hi\n2.\u{00A0}Hi\n3.\u{00A0}Hi")
    }
}
