//
//  String+.swift
//  funnelmink
//
//  Created by Jared Warren on 11/29/23.
//  Copyright © 2023 FunnelMink, LLC. All rights reserved.
//

import Foundation

extension String: LocalizedError {
    var localizedDescription: String { self }
    public var errorDescription: String? { self }
}

// MARK: formatting
extension String {
    func toDate() -> Date? {
        DateFormatter.funnelmink.date(from: self)
    }
    
    func toSortableDate() -> Date? {
        guard let date = DateFormatter.funnelmink.date(from: self) else { return nil }
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return Calendar.current.date(from: components)
    }
}

// MARK: constants
extension String {
    static let constants = Constants()
    static let storage = AppStorage()
    struct Constants {
        let refreshTokenExpiration = "refreshTokenExpiration"
    }
    
    struct AppStorage {
        let todaySortOrder = "todaySortOrder"
        let todayIsSearchable = "todayIsSearchable"
    }
}
