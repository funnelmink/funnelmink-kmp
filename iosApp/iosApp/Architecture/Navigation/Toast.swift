//
//  Toast.swift
//  iosApp
//
//  Created by Jared Warren on 1/21/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation
import Shared
import SwiftUI

struct ToastView: View {
    @ObservedObject var navigation = Navigation.shared
    
    @State private var isVisible = false
    
    let autoDismissDelay: TimeInterval = 2
    let toast: Toast
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: toast.type.icon)
                    .foregroundColor(toast.type.iconColor)
                Text(toast.message)
                    .foregroundStyle(.secondary)
                    .bold()
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .onTapGesture {
                navigation._state._toast = nil
                navigation._state._modalToast = nil
            }
            Spacer()
        }
        .padding()
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5)) {
                isVisible = true
            }
            navigation._state._dismissTask = Task {
                // Wait for the specified delay
                try await Task.sleep(for: .seconds(autoDismissDelay))
                
                withAnimation(.easeInOut(duration: 0.5)) {
                    isVisible = false
                }
                // After animation completes, remove the toast
                try await Task.sleep(for: .seconds(0.5))
                navigation._state._toast = nil
                navigation._state._modalToast = nil
            }
        }
    }
}

struct Toasted: ViewModifier {
    @ObservedObject var navigation = Navigation.shared
    let isPresented: Bool
    @ViewBuilder
    func body(content: Content) -> some View {
        if isPresented {
            modalToastView(content)
        } else {
            toastView(content)
        }
    }
    
    func toastView(_ content: Content) -> some View {
        ZStack {
            content
            if let toast = navigation._state._toast {
                ToastView(toast: toast)
            }
        }
    }
    
    func modalToastView(_ content: Content) -> some View {
        ZStack {
            content
            if let toast = navigation._state._modalToast {
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
    
    /// Notify user
    static func info(_ message: String) {
        Logger.info("🎊 TOAST INFO \(message)")
        Navigation.shared.toast(message)
    }
    
    /// Notify user of success
    static func success(_ message: String) {
        Logger.info("🎊 TOAST SUCCESS \(message)")
        Navigation.shared.toast(message, type: .success)
    }
    
    /// User did something wrong
    static func error(_ message: String) {
        Logger.error("🎊 TOAST ERROR \(message)")
        Navigation.shared.toast(message, type: .error)
    }
    
    /// User did something wrong
    static func error(_ error: Error) {
        Logger.error("🎊 TOAST ERROR \(error.localizedDescription)")
        Navigation.shared.toast(error.localizedDescription, type: .error)
    }
    
    /// We did something wrong
    static func warn(_ message: String) {
        Logger.warning("🎊 TOAST WARN \(message)")
        Navigation.shared.toast(message, type: .warn)
    }
    
    /// We did something wrong
    static func warn(_ error: Error) {
        Logger.warning("🎊 TOAST WARN \(error.localizedDescription)")
        Navigation.shared.toast(error.localizedDescription, type: .warn)
    }
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

extension Navigation {
    func toast(_ message: String, type: ToastType = .info) {
        guard !message.contains("Swift.CancellationError") else { return }
        _state._dismissTask?.cancel()
        let toast = Toast(message: message, type: type)
        withAnimation {
            if _state._sheet != nil || _state._fullscreen != nil {
                _state._modalToast = toast
            } else {
                _state._toast = toast
            }
        }
    }
}
