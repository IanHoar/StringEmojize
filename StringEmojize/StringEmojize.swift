//
//  StringEmojize.swift
//  StringEmojize
//
//  Created by Kyle Frost on 2/9/15.
//  Copyright (c) 2015 Kyle Frost. All rights reserved.
//

import Foundation

private let EmojiRegex: NSRegularExpression = try! NSRegularExpression(pattern: "(:[a-z0-9-+_]+:)", options: .caseInsensitive)
//private let EmojiRegex = NSRegularExpression(

extension String {
    
    func emojizedString() -> String {
        return self.emojizedStringWithString(self)
    }
    
    func emojizedStringWithString(_ text: String) -> String {
        var resultText = text
        let matchingRange = NSMakeRange(0, resultText.lengthOfBytes(using: String.Encoding.utf8))
        EmojiRegex.enumerateMatches(in: resultText, options: .reportCompletion, range: matchingRange, using: {
            (result: NSTextCheckingResult!, flags: NSRegularExpression.MatchingFlags, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                if ((result != nil) && (result.resultType == .regularExpression)) {
                    let range = result.range
                    if (range.location != NSNotFound) {
                        let code = (text as NSString).substring(with: range)
                        let unicode = EMOJI_HASH[code]!
                        if !unicode.isEmpty {
                            resultText = resultText.replacingOccurrences(of: code, with: unicode)
                        }
                    }
                }
        } as! (NSTextCheckingResult?, NSRegularExpression.MatchingFlags, UnsafeMutablePointer<ObjCBool>) -> Void)
        
        return resultText
    }
}

extension NSAttributedString {
    
    public func emojizedString() -> NSAttributedString {
        let mutableString = self.mutableCopy() as! NSMutableAttributedString
        mutableString.emojizeString()
        return mutableString.copy() as! NSAttributedString
    }
}

extension NSMutableAttributedString {
    
    public func emojizeString() {
        
        let text = self.string
        
        let matchingRange = NSMakeRange(0, self.length)
        let results = EmojiRegex.matches(in: text, options: [], range: matchingRange)

        for result in results.reversed() {
            if result.resultType != .regularExpression {
                continue
            }

            if result.range.location == NSNotFound {
                continue
            }
            
            let code = (text as NSString).substring(with: result.range)
            if let unicode = EMOJI_HASH[code] {
                if unicode.isEmpty {
                    continue
                }
                
                self.replaceCharacters(in: result.range, with: unicode)
            }
        }
    }
}
