//
//  DateFormatter+.swift
//  iosApp
//
//  Created by Jared Warren on 1/12/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation

extension DateFormatter {
    static let funnelmink: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}
