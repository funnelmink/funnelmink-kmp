//
//  ViewModifiers.swift
//  iosApp
//
//  Created by Jared Warren on 10/14/23.
//  Copyright © 2023 FunnelMink, LLC. All rights reserved.
//

import Foundation
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
}
