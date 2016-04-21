//
//  String+Searching.swift
//  NumberedLists
//
//  Created by Rhett Rogers on 3/7/16.
//  Copyright © 2016 LyokoTech. All rights reserved.
//

import Foundation

extension String {

    /// Gets the previous index of a substring contained within the `String`
    ///
    /// - parameter searchString: The string to search for
    /// - parameter fromIndex: The index to start the search from.  The search will move backwards from this index.
    ///
    /// - returns: Index of the searchString passed in. Nil if `fromIndex` is invalid, or if string is not found.
    func previousIndexOfSubstring(searchString: String, fromIndex: Int) -> Int? {
        if fromIndex < 0 {
            return nil
        }

        let substring = substringToIndex(characters.startIndex.advancedBy(fromIndex))
        if let range = substring.rangeOfString(searchString, options: .BackwardsSearch) {
            return substring.startIndex.distanceTo(range.startIndex)
        }

        return nil
    }

    /// Gets the next index of a substring contained within the `String`
    ///
    /// - parameter searchString: The string to search for
    /// - parameter fromIndex: The index to start the search from.  The search will move forwards from this index.
    ///
    /// - returns: Index of the searchString passed in. Nil if `fromIndex` is invalid, or if string is not found.
    func nextIndexOfSubstring(searchString: String, fromIndex: Int) -> Int? {
        if fromIndex < 0 {
            return nil
        }
        
        let substring = substringFromIndex(characters.startIndex.advancedBy(fromIndex))
        if let range = substring.rangeOfString(searchString) {
            return substring.startIndex.distanceTo(range.startIndex) + fromIndex
        }

        return nil
    }

    var length: Int {
        return (self as NSString).length
    }

}