//
//  Date+RandomBetween.swift
//  
//
//  Created by Alex Loren on 8/28/22.
//

import Foundation

extension Date {
    /// Returns a random `Date` between two dates.
    /// - Parameters:
    ///   - start: The earliest date to be considered.
    ///   - end: The latest date to be considered.
    ///   - format: The format of the `start` and `end` dates; in "yyyy-MM-dd" format.
    /// - Returns: A `Date` object within the given range.
    static func randomBetween(start: String, end: String, format: String = "yyyy-MM-dd") -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        let timeSpan = TimeInterval.random(in: formatter.date(from: start)!.timeIntervalSinceNow ... formatter.date(from: end)!.timeIntervalSinceNow)
        return Date(timeIntervalSinceNow: timeSpan)
    }
}
