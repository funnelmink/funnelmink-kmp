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
    /// 12 o'clock noon today in the user's current time zone
    static var noon: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: Date())
        return calendar.date(from: components) ?? Date()
    }
    
    /// The format our backend sends and receives dates in
    func iso8601() -> String {
        DateFormatter.iso8601.string(from: self)
    }
    
    /// "Today • Dec 25 • Saturday"
    func toTaskSectionTitle() -> String {
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.month, .day, .weekday], from: self)
        
        let todayComponents = calendar.dateComponents([.month, .day, .weekday], from: Date())
        
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        let tomorrowComponents = calendar.dateComponents([.month, .day, .weekday], from: tomorrow)
        
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        let yesterdayComponents = calendar.dateComponents([.month, .day, .weekday], from: yesterday)

        let month = components.month ?? 1
        let day = components.day ?? 1
        
        let monthArray = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let weekdayArray = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        
        var output = ""
        
        if components == todayComponents {
            output = "Today • "
        } else if components == tomorrowComponents {
            output = "Tomorrow • "
        } else if components == yesterdayComponents {
            output = "Yesterday • "
        }
        
        output += "\(monthArray[month - 1]) \(day) • \(weekdayArray[(components.weekday ?? 1) - 1])"
        return output
    }
}
