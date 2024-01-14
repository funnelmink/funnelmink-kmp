//
//  Date+.swift
//  iosApp
//
//  Created by Jared Warren on 1/12/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation
import Shared

extension Date {
    func toFunnelminkString() -> String {
        DateFormatter.funnelmink.string(from: self)
    }
    
    func toNumberRelativeAndWeekday() -> String {
        let components = Calendar.current.dateComponents([.month, .day, .weekday], from: self)
        let month = components.month ?? 1
        var monthString = ""
        switch month {
        case 1: monthString = "Jan"
        case 2: monthString = "Feb"
        case 3: monthString = "Mar"
        case 4: monthString = "Apr"
        case 5: monthString = "May"
        case 6: monthString = "Jun"
        case 7: monthString = "Jul"
        case 8: monthString = "Aug"
        case 9: monthString = "Sep"
        case 10: monthString = "Oct"
        case 11: monthString = "Nov"
        case 12: monthString = "Dec"
        default: break
        }
        var weekdayString = ""
        switch components.weekday {
        case 1: weekdayString = "Sunday"
        case 2: weekdayString = "Monday"
        case 3: weekdayString = "Tuesday"
        case 4: weekdayString = "Wednesday"
        case 5: weekdayString = "Thursday"
        case 6: weekdayString = "Friday"
        case 7: weekdayString = "Saturday"
        default: break
        }
        return "\(monthString) \(components.day ?? 1) • \(weekdayString)"
    }
}
