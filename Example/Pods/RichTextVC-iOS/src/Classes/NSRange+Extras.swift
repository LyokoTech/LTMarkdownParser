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
    
    func containsEntireRange(_ range: NSRange) -> Bool {
        return containsBeginningOfRange(range) && containsEndOfRange(range)
    }
    
    func containedInRange(_ range: NSRange) -> Bool {
        return range.containsEntireRange(self)
    }
    
    func containsEndOfRange(_ range: NSRange) -> Bool {
        return length > 0 && location <= range.endLocation && range.endLocation < endLocation
    }
    
    func containsBeginningOfRange(_ range: NSRange) -> Bool {
        return length > 0 && location <= range.location && endLocation >= range.location
    }
    
    func comesBeforeRange(_ range: NSRange) -> Bool {
        return endLocation <= range.location
    }
    
    func comesAfterRange(_ range: NSRange) -> Bool {
        return range.comesBeforeRange(self)
    }
    
}
