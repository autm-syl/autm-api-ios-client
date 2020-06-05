//
//  Utility.swift
//  AuthLipstick
//
//  Created by Sylvanas on 11/12/19.
//  Copyright © 2019 Sylvanas. All rights reserved.
//

import Foundation
import UIKit

public class Utility {
    func currentDateToString() -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let now = df.string(from: Date())
        return now;
    }
    
    func resizeImageTofill(image:UIImage) -> UIImage{
        let size = image.size

        let ratio  = 1000  / size.width

        // Figure out what our orientation is, and use that to form the rectangle
        let newSize = CGSize.init(width: 1000, height: size.height * ratio)

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect.init(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}

extension String {
    private static let slugSafeCharacters = CharacterSet(charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-")

    public func convertedToSlug() -> String? {
        if let latin = self.applyingTransform(StringTransform("Any-Latin; Latin-ASCII; Lower;"), reverse: false) {
            return latin
        }

        return self;
    }
    
    func substring(from: Int, to: Int) -> String {
        let start = index(startIndex, offsetBy: from)
            let end = index(start, offsetBy: to - from)
            return String(self[start ..< end])
        }
        
        func substring(range: NSRange) -> String {
            return substring(from: range.lowerBound, to: range.upperBound)
        }
        
        
        // formatting text for currency textField
    public func currencyInputFormatting() -> String {
        
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.positiveFormat = "¤ #,##0"
        formatter.negativeFormat = "¤ -#,##0"
        formatter.currencySymbol = "VND"
        formatter.maximumFractionDigits = 3
        formatter.minimumFractionDigits = 0
        
        var amountWithPrefix = self
        
        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")
        
        let intValue = (amountWithPrefix as NSString).integerValue
        number = NSNumber(value: (intValue))
        
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }
        
//        var amount = number.stringValue
        
//        return amount;
        return formatter.string(from: number)!
    }
    
}
