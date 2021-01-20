//
//  SwiftExtensions.swift
//  DeserveCard
//
//  Created by Swapnil Jadhav on 29/11/19.
//  Copyright © 2019 Deserve Inc. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: .whitespaces)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }

    func validURL() -> URL? {
        guard !isEmpty else {
            return nil
        }
        if let url = URL(string: self) {
            return url
        } else {
            if let urlEscapedString = addingPercentEncoding(
                withAllowedCharacters: CharacterSet.urlQueryAllowed) ,
                let escapedURL = URL(string: urlEscapedString) {
                return escapedURL
            }
        }
        return nil
    }

    func separate(every stride: Int = 4, with separator: Character = " ") -> String {
        return String(enumerated().map { $0 > 0 && $0 % stride == 0 ? [separator, $1] : [$1]}.joined())
    }

    func capitalizingFirstLetter() -> String {
        let first = String(prefix(1)).capitalized
        let other = String(dropFirst()).lowercased()
        return first + other
    }

    func withDollarPrefix() -> String {
        return "$\(self)"
    }

    func size(forConstraintRect rect: CGSize, attributes: [NSAttributedString.Key: Any]) -> CGSize {
        let boundingBox = self.boundingRect(
            with: rect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil)
        return boundingBox.size
    }
}

extension Float {
    func toInt() -> Int? {
        if self > Float(Int.min) && self < Float(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }
}

extension Double {
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    // If you don't want your code crash on each overflow, use this function that operates on optionals
    // E.g.: Int(Double(Int.max) + 1) will crash:
    // fatal error: floating point value can not be converted to Int because it is greater than Int.max
    func toInt() -> Int? {
        if self > Double(Int.min) && self < Double(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }

    var stringWithoutZeroFraction: String {
        return truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

extension Int {
    var digitCount: Int {
        get {
            return numberOfDigits(in: self)
        }
    }

    private func numberOfDigits(in number: Int) -> Int {
        if number < 10 && number >= 0 || number > -10 && number < 0 {
            return 1
        } else {
            return 1 + numberOfDigits(in: number/10)
        }
    }
}

extension Date {
    var month: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: self)
    }

    // This will return month's day between 1 to 31
    static func timestampToMonthDay(_ timestamp: Double) -> Int {
        let date =  Date(timeIntervalSince1970: timestamp)
        let calendar = Calendar.current
        let components = calendar.dateComponents(
                            [.day],
                            from: date)
        return components.day ?? -1
    }

    static func timestampToMMMddformat(_ timeStamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timeStamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        return dateFormatter.string(from: date).uppercased()
    }

    func dateComponents() -> DateComponents {
        let calendar = Calendar.current
        let components = calendar.dateComponents(
            [.day, .month, .year, .weekday, .weekdayOrdinal, .weekOfMonth, .weekOfYear],
            from: self)
        return components
    }

    func dayInMonth() -> Int {
        let calendar = Calendar.current
        return calendar.component(.day, from: self)
    }

    func numberOfDaysInMonth() -> Int {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: self) else {
            return 0
        }
        return range.count
    }

    func toString(dateFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

extension Double {
    func string(decimalPlaces: Int = 2) -> String {
        let formatter = NumberFormatter()
        let number = NSNumber(value: self)
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = decimalPlaces
        return String(formatter.string(from: number) ?? "")
    }
}

extension Error {
    func isNotConnectedToInternet() -> Bool {
        let errorCode = URLError.Code(rawValue: (self as NSError).code)
        return errorCode == .notConnectedToInternet
    }
}

extension Dictionary {
    func jsonString() -> String? {
        let jsonDataOptional = try? JSONSerialization.data(withJSONObject: self, options: [])
        guard let jsonData = jsonDataOptional else { return nil }
        let jsonString = String(data: jsonData, encoding: .utf8)
        return jsonString
    }    
}
