//
//  ViewModifiers.swift
//  iosApp
//
//  Created by Jared Warren on 10/14/23.
//  Copyright © 2023 FunnelMink, LLC. All rights reserved.
//

import Foundation
import Shared
import SwiftUI

struct MinkCard: ViewModifier {
    var foregroundColor: Color
    var backgroundColor: Color
    var backgroundOverlay: Color = .clear
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(foregroundColor)
            .padding()
            .background(backgroundColor.overlay(backgroundOverlay))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .shadow(radius: 1)
    }
}

extension View {
    func maxReadableWidth() -> some View {
        self.frame(maxWidth: .maximumReadableWidth)
    }
    
    func loggedTask(id: String = #fileID, action: @escaping () async -> Void) -> some View{
        self.task {
            // Drop the `funnelmink/` and `.swift` from each file ID
            Logger.view("\(id.dropFirst(11).dropLast(6))")
            await action()
        }
    }
    
    func loggedOnAppear(id: String = #fileID, action: @escaping () -> Void) -> some View {
        self.onAppear {
            // Drop the `funnelmink/` and `.swift` from each file ID
            Logger.view("\(id.dropFirst(11).dropLast(6))")
            action()
        }
    }
    
    func logged(id: String = #fileID) -> some View {
        self.onAppear {
            // Drop the `funnelmink/` and `.swift` from each file ID
            Logger.view("\(id.dropFirst(11).dropLast(6))")
        }
    }
    
    func requiredIndicator(isVisible: Bool) -> some View {
        self.modifier(RequiredModifier(isVisible: isVisible))
    }
}

struct RequiredModifier: ViewModifier {
    let isVisible: Bool
    func body(content: Content) -> some View {
        content
            .overlay {
                if isVisible {
                    VStack {
                        HStack {
                            Spacer()
                            Text("*")
                                .font(.title)
                                .foregroundStyle(.red)
                        }
                        Spacer()
                    }
                }
            }
    }
}
