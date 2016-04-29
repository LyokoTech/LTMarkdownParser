import Foundation
import UIKit

public extension NSAttributedString {
    
    public func markdownString() -> String {
        let bulletCharacter = Character("\u{2022}")
        let nonBreakingSpaceCharacter = Character("\u{00A0}")
        
        var markdownString = ""
        
        enum FormattingChange {
            case Enable
            case Disable
            case Keep
            
            static func getFormattingChange(before: Bool, after: Bool) -> FormattingChange {
                if !before && after { return .Enable }
                if before && !after { return .Disable }
                return .Keep
            }
        }
        
        var stringHasBoldEnabled = false
        var stringHasItalicEnabled = false
        var closingString = ""
        var characterOnBulletedListLine = false
        var openedNumberedListStarter = false
        var characterOnNumberedListLine = false
        var numberedListIsFirstLine = false
        var previousCharacter: Character?
        enumerateAttributesInRange(NSRange(location: 0, length: length), options: []) { attributes, range, shouldStop in
            if let traits = (attributes[NSFontAttributeName] as? UIFont)?.fontDescriptor().symbolicTraits {
                let boldChange = FormattingChange.getFormattingChange(stringHasBoldEnabled, after: traits.contains(.TraitBold))
                let italicChange = FormattingChange.getFormattingChange(stringHasItalicEnabled, after: traits.contains(.TraitItalic))
                var formatString = ""
                switch boldChange {
                case .Enable:
                    formatString += "**"
                    closingString = "**\(closingString)"
                case .Disable:
                    if stringHasItalicEnabled && italicChange == .Keep {
                        formatString += "_**_"
                        closingString = "_"
                    } else {
                        formatString += "**"
                        closingString = ""
                    }
                case .Keep:
                    break
                }
                
                switch italicChange {
                case .Enable:
                    formatString += "_"
                    closingString = "_\(closingString)"
                case .Disable:
                    if stringHasBoldEnabled && boldChange == .Keep {
                        formatString = "**_**\(formatString)"
                        closingString = "**"
                    } else {
                        formatString = "_\(formatString)"
                        closingString = ""
                    }
                case .Keep:
                    break
                }
                
                markdownString += formatString
                
                stringHasBoldEnabled = traits.contains(.TraitBold)
                stringHasItalicEnabled = traits.contains(.TraitItalic)
            }
            
            let preprocessedString = (self.string as NSString).substringWithRange(range)
            let processedString = preprocessedString.characters.reduce("") { resultString, character in
                var stringToAppend = ""
                
                switch character {
                case "\\", "`", "*", "_", "{", "}", "[", "]", "(", ")", "#", "+", "-", "!":
                    stringToAppend = "\\\(character)"
                case "\n", "\u{2028}":
                    stringToAppend = "\(closingString)\(character)"
                    if !characterOnBulletedListLine && !characterOnNumberedListLine {
                        stringToAppend += String(closingString.characters.reverse())
                    }
                    
                    characterOnBulletedListLine = false
                    characterOnNumberedListLine = false
                case "1", "2", "3", "4", "5", "6", "7", "8", "9", "0":
                    if previousCharacter == "\n" || previousCharacter == nil || previousCharacter == nonBreakingSpaceCharacter {
                        openedNumberedListStarter = true
                    }
                    
                    numberedListIsFirstLine = previousCharacter == nil ? true : numberedListIsFirstLine
                    stringToAppend = "\(character)"
                case bulletCharacter:
                    characterOnBulletedListLine = true
                    stringToAppend = "+ \(previousCharacter != nil ? String(closingString.characters.reverse()) : markdownString)"
                    markdownString = previousCharacter == nil ? "" : markdownString
                case ".":
                    if openedNumberedListStarter {
                        openedNumberedListStarter = false
                        characterOnNumberedListLine = true
                        
                        stringToAppend = "\(character) \(!numberedListIsFirstLine ? String(closingString.characters.reverse()) : markdownString)"
                        
                        if numberedListIsFirstLine {
                            markdownString = ""
                            numberedListIsFirstLine = false
                        }
                        break
                    }
                    stringToAppend = "\\\(character)"
                case nonBreakingSpaceCharacter:
                    if characterOnBulletedListLine || characterOnNumberedListLine {
                        break
                    }
                    stringToAppend = " "
                default:
                    if (previousCharacter == "\n" || previousCharacter == "\u{2028}") && characterOnBulletedListLine {
                        characterOnBulletedListLine = false
                        stringToAppend = "\(String(closingString.characters.reverse()))\(character)"
                    } else {
                        stringToAppend = "\(character)"
                    }
                }
                
                previousCharacter = character
                return "\(resultString)\(stringToAppend)"
            }
            
            
            markdownString += processedString
        }
        markdownString += closingString
        markdownString = markdownString.stringByReplacingOccurrencesOfString("****", withString: "")
            .stringByReplacingOccurrencesOfString("__", withString: "")
        return markdownString
    }
    
}
