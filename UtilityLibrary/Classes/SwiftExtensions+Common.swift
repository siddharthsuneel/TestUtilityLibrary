//
//  SwiftExtensions+Common.swift
//  Deserve
//
//  Created by Amit Bobade on 24/12/20.
//  Copyright © 2020 Deserve Inc. All rights reserved.
//

import Foundation
import UIKit

extension String {
    var length: Int { return self.count }

    static func unique() -> String {
        return UUID().uuidString
    }

    func removeWhitespace() -> String {
        return self.replace(string: " ", replacement: "")
    }

    func replace(string: String, replacement: String) -> String {
        return self.replacingOccurrences(of: string,
                                         with: replacement,
                                         options: NSString.CompareOptions.literal,
                                         range: nil)
    }

    func height(forConstrainedWidth width: CGFloat, attributes: [NSAttributedString.Key: Any]) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil)
        return boundingBox.height
    }

    func loadJsonIfAvailable() -> String? {
        guard let fileUrl = Bundle.main.path(forResource: self, ofType: "json") else {
            return nil
        }
        do {
            let contents = try String(contentsOfFile: fileUrl)
            return contents
        } catch {
            return nil
        }
    }

    //    /*
    //     Truncates the string to the
    //    specified length number of characters and
    //    appends an optional trailing string if longer.
    //     - Parameter length: Desired maximum lengths of a string
    //     - Parameter trailing: A 'String' that will be appended after the truncation.
    //
    //     - Returns: 'String' object.
    //    */
    //    func trunc(length: Int, trailing: String = "…") -> String {
    //      return (self.count > length) ? self.prefix(length) + trailing : self
    //    }

    enum TruncationPosition {
        case head
        case middle
        case tail
    }

    func truncated(
        limit: Int,
        position: TruncationPosition = .tail,
        leader: String = "...") -> String {

        guard self.count > limit else { return self }

        switch position {
        case .head:
            return leader + self.suffix(limit)

        case .middle:
            let headCharactersCount = Int(ceil(Float(limit - leader.count) / 2.0))
            let tailCharactersCount = Int(floor(Float(limit - leader.count) / 2.0))
            return "\(self.prefix(headCharactersCount))\(leader)\(self.suffix(tailCharactersCount))"

        case .tail:
            return self.prefix(limit) + leader
        }
    }

    // MARK: Encoding / Decoding
    // Assuming the current string is base64 encoded, this property returns a String
    // initialized by converting the current string into Unicode characters, encoded to
    // utf8. If the current string is not base64 encoded, nil is returned instead.
    var base64Decoded: String? {
        guard let base64 = Data(base64Encoded: self) else { return nil }
        let utf8 = String(data: base64, encoding: .utf8)
        return utf8
    }

    // Returns a base64 representation of the current string, or nil if the
    // operation fails.
    var base64Encoded: String? {
        let utf8 = data(using: .utf8)
        let base64 = utf8?.base64EncodedString()
        return base64
    }

    func decodeBase64(addPaddingIfRequired: Bool = false) -> String? {
        let encodedStr = addPaddingIfRequired ? base64PaddingIfRequired() : self
        return encodedStr.base64Decoded
    }
    
    var decodedJWTTokenStr: String? {
        let tokenStrings = split(separator: Character("."), maxSplits: 3, omittingEmptySubsequences: true)
        guard tokenStrings.count >= 3 else {
            DLog("JWT Token after separting by dots is not as per expectation.", logLevel: .error)
            return nil
        }

        let base64EncodedStr = String(tokenStrings[1])
        guard
            let decodedString = base64EncodedStr.decodeBase64(addPaddingIfRequired: true)
            else {
                DLog("JWT Token failed to decode!", logLevel: .error)
                return nil
        }
        return decodedString
    }

    var isEmailPresentInJwtToken: Bool {
        guard let decodedString = self.decodedJWTTokenStr else {
            return false
        }
        let email = AppleIdTokenPayload(JSONString: decodedString)?.email
        return email != nil
    }

    // MARK: Private Methods
    /**
     Sometimes base64 decoding method requires padding with “=“, the length of the string must be multiple of 4.

     In some implementations of base64 the padding character is not needed for decoding,
     since the number of missing bytes can be calculated. But in Fundation's implementation it is mandatory.

     Note, when the number of characters is divisible by 4, you do not need padding.
     */
    private func base64PaddingIfRequired() -> String {
        let remainder = count % 4
        guard remainder != 0 else {
            return self
        }

        // padding with equal
        let newLength = count + (4 - remainder)
        return padding(toLength: newLength, withPad: "=", startingAt: 0)
    }
}

extension NSMutableAttributedString {
    @discardableResult
    func setAsLink(textToFind: String, linkURL: String) -> Bool {
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(.link, value: linkURL, range: foundRange)
            return true
        }
        return false
    }
}

extension Date {
    static func dateFrom(_ dateFormat: String, dateInString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.date(from: dateInString)
    }
}

extension Dictionary {
    func jsonData() -> Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: [])
    }
}

extension Data {
    var jwtTokenStr: String? {
        return String(data: self, encoding: .utf8)
    }
}
