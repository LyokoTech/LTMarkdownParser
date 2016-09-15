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
    func previousIndexOfSubstring(_ searchString: String, fromIndex: Int) -> Int? {
        if fromIndex < 0 {
            return nil
        }

        let substring = self.substring(to: characters.index(characters.startIndex, offsetBy: fromIndex))
        if let range = substring.range(of: searchString, options: .backwards) {
            return substring.characters.distance(from: substring.startIndex, to: range.lowerBound)
        }

        return nil
    }

    /// Gets the next index of a substring contained within the `String`
    ///
    /// - parameter searchString: The string to search for
    /// - parameter fromIndex: The index to start the search from.  The search will move forwards from this index.
    ///
    /// - returns: Index of the searchString passed in. Nil if `fromIndex` is invalid, or if string is not found.
    func nextIndexOfSubstring(_ searchString: String, fromIndex: Int) -> Int? {
        if fromIndex < 0 {
            return nil
        }
        
        let substring = self.substring(from: characters.index(characters.startIndex, offsetBy: fromIndex))
        if let range = substring.range(of: searchString) {
            return substring.characters.distance(from: substring.startIndex, to: range.lowerBound) + fromIndex
        }

        return nil
    }

    var length: Int {
        return (self as NSString).length
    }

}
