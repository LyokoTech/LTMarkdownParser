//
//  NSAttributedString+MarkdownTests.swift
//  TSSwiftMarkdownParser
//
//  Created by Rhett Rogers on 4/13/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import XCTest
import TSSwiftMarkdownParser

class NSAttributedStringTests: XCTestCase {
    func testTextWithNoFormatting() {
        assertRoundTripFromMarkdownString("Some text that does not have formatting")
    }
    
    func testBoldAcrossTwoLines() {
        assertRoundTripFromMarkdownString("Some text **that has bolded**   \n**text across two lines**")
    }
    
    func testBoldWithItalic() {
        assertRoundTripFromMarkdownString("Some text that has _italics and **bold**_")
    }
    
    func testMultipleFormatting() {
        let strings = [
            "**Markdown _double_**_ something_",
            "_italic **double**_** bold**"
        ]
        
        for string in strings {
            assertRoundTripFromMarkdownString(string)
        }
    }
    
    func testLotsOfCases() {
        let strings = [
            "Bible **studies**   \n&nbsp;  \n+ jailed \n+ skd \n+ skd",
            "hello",
            "**something**",
            "bible **studies**   \n**open the door**"
        ]
        
        for string in strings {
            assertRoundTripFromMarkdownString(string)
        }
    }
    
    func testTwoLineBreaks() {
        assertRoundTripFromMarkdownString("Some text   \n&nbsp;  \nthat has two line breaks between it")
    }
    
    func testUnorderedList() {
        assertRoundTripFromMarkdownString("+ Item 1\n+ Item 2\n+ **Bolded Item 3**\n+ _Italicized Item 4_")
    }
    
    func testMultilineUnorderedList() {
        let attributedString = NSAttributedString(string: "\u{2022}\u{00A0}Some Text\n\u{2022}\u{00A0}Some other text")
        let markdown = "+ Some Text\n+ Some other text"
        XCTAssertEqual(attributedString.markdownString(), markdown)
    }
    
    func testEscapedMarkdownCharacters() {
        let attributedString = NSAttributedString(string: "This is text that has characters like *,+,- that aren't supposed to be converted to markdown.")
        let escapedMarkdown = "This is text that has characters like \\*,\\+,\\- that aren't supposed to be converted to markdown\\."
        XCTAssertEqual(attributedString.markdownString(), escapedMarkdown)
    }
    
    func testEscapedMarkdownCharactersThatHavePairs() {
        let attributedString = NSAttributedString(string: "This is text that looks like it should be _italicized_ or **bolded**, but really isn't because it wasn't written in markdown.")
        let escapedMarkdown = "This is text that looks like it should be \\_italicized\\_ or \\*\\*bolded\\*\\*, but really isn't because it wasn't written in markdown\\."
        XCTAssertEqual(attributedString.markdownString(), escapedMarkdown)
    }
    
    func assertRoundTripFromMarkdownString(markdownString: String) {
        let attributedString = TSSwiftMarkdownParser(withDefaultParsing: true).attributedStringFromMarkdown(markdownString)
        XCTAssertEqual(attributedString!.markdownString(), markdownString)
    }
}