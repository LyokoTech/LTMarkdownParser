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
        return containsBeginningOfRange(range) && containsEndOfRange(range)
    }
    
    func containedInRange(range: NSRange) -> Bool {
        return range.containsEntireRange(self)
    }
    
    func containsEndOfRange(range: NSRange) -> Bool {
        return length > 0 && location <= range.endLocation && range.endLocation < endLocation
    }
    
    func containsBeginningOfRange(range: NSRange) -> Bool {
        return length > 0 && location <= range.location && endLocation >= range.location
    }
    
    func comesBeforeRange(range: NSRange) -> Bool {
        return endLocation <= range.location
    }
    
    func comesAfterRange(range: NSRange) -> Bool {
        return range.comesBeforeRange(self)
    }
    
}
