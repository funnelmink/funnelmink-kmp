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
    static var loremShort: String { "Lorem ipsum dolor sit amet" }
    static var loremMedium: String { "Lorem ipsum dolor sit amet, consectetur adipiscing elit." }
    static var loremLong: String { "Lorem ipsum dolor sit amet, consectetur adipiscing elit. In condimentum, risus mollis gravida aliquet, risus sem pulvinar metus, vel consectetur metus elit quis arcu." }
    static var loremDate: String { "2024-01-20T00:31:00-03:00" }
}

// MARK: formatting
extension String {
    func toDate() -> Date? {
        DateFormatter.iso8601.date(from: self)
    }
    
    func toSortableDate() -> Date? {
        guard let date = DateFormatter.iso8601.date(from: self) else { return nil }
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
        let todaySelection = "todaySelection"
    }
}
