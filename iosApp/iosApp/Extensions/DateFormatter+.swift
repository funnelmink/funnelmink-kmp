//
//  DateFormatter+.swift
//  iosApp
//
//  Created by Jared Warren on 1/12/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation

extension DateFormatter {
    /// The format our backend sends and receives dates in
    static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}
