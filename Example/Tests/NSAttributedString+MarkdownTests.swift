//
//  NSAttributedString+MarkdownTests.swift
//  LTMarkdownParser
//
//  Created by Rhett Rogers on 4/13/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import XCTest
import LTMarkdownParser

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
        
        strings.forEach { assertRoundTripFromMarkdownString($0) }
    }
    
    func testLotsOfCases() {
        let strings = [
            "Bible **studies**\n\n+ jailed\n+ skd\n+ skd",
            "hello",
            "**something**",
            "bible **studies**\n**open the door**"
        ]
        
        strings.forEach { assertRoundTripFromMarkdownString($0) }
    }
    
    func testNumberedLists() {
        assertRoundTripFromMarkdownString("1. Hi\n2. Hi\n3. Hi\n")
    }
    
    func testNumberedListsWithFormatting() {
        let strings = [
            "1. **this list has some bolded strings**\n2. **does it translate?**",
            "1. _this list has some bolded strings_\n2. **does it translate?**",
            "1. **this list has some bolded strings**\n2. _does it translate?_",
            "1. _this list has some bolded strings_\n2. _does it translate?_",
            "1. **this list has some bolded strings**\n2. **does it translate?**\n\n_I am also writing something in italics_"
        ]
        
        strings.forEach(assertRoundTripFromMarkdownString)
    }
    
    func testBulletedLists() {
        assertRoundTripFromMarkdownString("+ Hi\n+ hi\n+ Hi")
    }
    
    func testBulletedListsWithFormatting() {
        let strings = [
            "+ **this list has some bolded strings**\n+ **does it translate?**",
            "+ _this list has some bolded strings_\n+ **does it translate?**",
            "+ **this list has some bolded strings**\n+ _does it translate?_",
            "+ _this list has some bolded strings_\n+ _does it translate?_",
            "+ **this list has some bolded strings**\n+ **does it translate?**\n\n_I am also writing something in italics_"
        ]
        
        strings.forEach(assertRoundTripFromMarkdownString)
    }
    
    func testBulletedFollowedByNumbered() {
        assertRoundTripFromMarkdownString("+ a bullet\n1. a number\n2. another number")
    }
    
    func testTwoLineBreaks() {
        assertRoundTripFromMarkdownString("Some text\n\nthat has two line breaks between it")
    }
    
    func testUnorderedList() {
        assertRoundTripFromMarkdownString("+ Item 1\n+ Item 2\n+ **Bolded Item 3**\n+ _Italicized Item 4_")
    }
    
    func testMultilineUnorderedList() {
        let attributedString = NSAttributedString(string: "\u{2022}\u{00A0}Some Text\n\u{2022}\u{00A0}Some other text")
        let markdown = "+ Some Text\n+ Some other text"
        XCTAssertEqual(attributedString.markdownString(), markdown)
    }
    
    func testLevelledLists() {
        let strings = [
            "+ Level One\n + Level Two\n  + Level Three",
            "1. Level One\n 1. Level Two\n  1. Level Three"
        ]
        
        strings.forEach(assertRoundTripFromMarkdownString)
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
        let attributedString = LTMarkdownParser(withDefaultParsing: true).attributedStringFromMarkdown(markdownString)
        XCTAssertEqual(attributedString!.markdownString(), markdownString)
    }
    
}
