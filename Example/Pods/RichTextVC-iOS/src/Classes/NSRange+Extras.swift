//
//  NSRange+Range.swift
//  NumberedLists
//
//  Created by Rhett Rogers on 3/7/16.
//  Copyright © 2016 LyokoTech. All rights reserved.
//

import Foundation


extension NSRange {

    var endLocation: Int {
        return location + length
    }
    
    func containsEntireRange(range: NSRange) -> Bool {
        return (location < range.location) && ((range.location - location) + range.length <= length)
    }
    
    func containedInRange(range: NSRange) -> Bool {
        return range.containsEntireRange(self)
    }
    
    func containsEndOfRange(range: NSRange) -> Bool {
        return location < range.endLocation && range.endLocation < endLocation
    }
    
    func containsBeginningOfRange(range: NSRange) -> Bool {
        return range.location < endLocation && endLocation < range.endLocation
    }
    
    func comesBeforeRange(range: NSRange) -> Bool {
        return endLocation < range.location
    }
    
    func comesAfterRange(range: NSRange) -> Bool {
        return range.comesBeforeRange(self)
    }
    
}
