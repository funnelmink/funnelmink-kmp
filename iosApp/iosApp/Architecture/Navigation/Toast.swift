//
//  Toast.swift
//  iosApp
//
//  Created by Jared Warren on 1/21/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation
import SwiftUI

struct Toasty: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            content
//            if toastManager.isPresenting {
//                ToastView() // Your custom toast view
//                    .animation(.default)
//                    .transition(.move(edge: .top))
//                    // Additional logic for dismissal and animation
//            }
        }
    }
}

extension View {
    /// Modifies the view to be able to display toasts
    func toasty() -> some View {
        self.modifier(Toasty())
    }
}

struct Toast: Hashable, Equatable {
    let message: String
    let type: ToastType
}

enum ToastType {
    case success
    case error
    case info
    case warn
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.octagon.fill"
        case .info: return "info.circle.fill"
        case .warn: return "exclamationmark.triangle.fill"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .info: return .blue
        case .warn: return .yellow
        }
    }
}
