//
//  Toast.swift
//  iosApp
//
//  Created by Jared Warren on 1/21/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation
import SwiftUI

struct ToastView: View {
    @ObservedObject var navigation = Navigation.shared
    let toast: Toast
    var body: some View {
        VStack {
            Button {
                navigation._state._toast = nil
                navigation._state._modalToast = nil
            } label: {
                HStack {
                    Image(systemName: toast.type.icon)
                        .foregroundColor(toast.type.iconColor)
                    Text(toast.message)
                        .foregroundStyle(.primary)
                }
                .padding()
                .padding(.horizontal)
                .background(.regularMaterial)
                .clipShape(Capsule())
            }
            Spacer()
        }
    }
}

struct Toasted: ViewModifier {
    @ObservedObject var navigation = Navigation.shared
    let isPresented: Bool
    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented, let toast = navigation._state._modalToast {
                ToastView(toast: toast)
            } else if let toast = navigation._state._toast {
                ToastView(toast: toast)
            }
        }
    }
}

extension View {
    /// Enables the view to display toasts
    func toasted(isPresented: Bool = false) -> some View {
        self.modifier(Toasted(isPresented: isPresented))
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
