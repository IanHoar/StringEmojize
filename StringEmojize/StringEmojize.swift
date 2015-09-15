//
//  StringEmojize.swift
//  StringEmojize
//
//  Created by Kyle Frost on 2/9/15.
//  Copyright (c) 2015 Kyle Frost. All rights reserved.
//

import Foundation

private let EmojiRegex = try! NSRegularExpression(pattern: "(:[a-z0-9-+_]+:)", options: .CaseInsensitive)

extension String {
    
    public func emojizedString() -> String {
        return self.emojizedStringWithString(self)
    }
    
    public func emojizedStringWithString(text: String) -> String {
        var resultText = text
        let matchingRange = NSMakeRange(0, resultText.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        EmojiRegex.enumerateMatchesInString(resultText, options: .ReportCompletion, range: matchingRange, usingBlock: {
            (result: NSTextCheckingResult?, flags: NSMatchingFlags, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
          guard let result = result where result.resultType == .RegularExpression else { return }

          let range = result.range
          if (range.location != NSNotFound) {
            let code = (text as NSString).substringWithRange(range)
            let unicode = EMOJI_HASH[code]!
            if !unicode.isEmpty {
              resultText = resultText.stringByReplacingOccurrencesOfString(code, withString:unicode, options: [], range: nil)
            }
          }
        })

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
        let results = EmojiRegex.matchesInString(text, options: NSMatchingOptions(rawValue: 0), range: matchingRange)
        
        for result in Array(results.reverse()) {
            if result.resultType != .RegularExpression {
                continue
            }
            
            if result.range.location == NSNotFound {
                continue
            }
            
            let code = (text as NSString).substringWithRange(result.range)
            if let unicode = EMOJI_HASH[code] {
                if unicode.isEmpty {
                    continue
                }
                
                self.replaceCharactersInRange(result.range, withString: unicode)
            }
        }
    }
}
