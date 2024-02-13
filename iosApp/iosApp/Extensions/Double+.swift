//
//  Double+.swift
//  iosApp
//
//  Created by Jared Warren on 1/22/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation
import Shared

extension Double {
    var kotlinValue: KotlinDouble {
        KotlinDouble(double: self)
    }
    
    var currencyFormat: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: self)) ?? "$\(self)"
    }
}
