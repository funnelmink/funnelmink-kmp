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

// MARK: constants
extension String {
    static let constants = Constants()
    struct Constants {
        let refreshTokenExpiration = "refreshTokenExpiration"
    }
}
