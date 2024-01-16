//
//  Int32+.swift
//  iosApp
//
//  Created by Jared Warren on 1/14/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation
import SwiftUI

extension Int32 {
    var priorityColor: Color {
        switch self {
        case 1: return .blue
        case 2: return .purple
        case 3: return .red
        default: return .gray
        }
    }
    
    var priorityIconName: String {
        switch self {
        case 1: return "gauge.with.dots.needle.33percent"
        case 2: return "gauge.with.dots.needle.67percent"
        case 3: return "gauge.with.dots.needle.100percent"
        default: return "gauge.with.dots.needle.0percent"
        }
    }
    
    var priorityName: String {
        switch self {
        case 1: return "Medium"
        case 2: return "High"
        case 3: return "Ultra"
        default: return "Low"
        }
    }
}
