//
//  SwiftUI+.swift
//  iosApp
//
//  Created by Jared Warren on 10/14/23.
//  Copyright © 2023 FunnelMink, LLC. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    func withPreviewDependencies() -> some View {
        self
            .toasted()
            .environmentObject(AppState.shared)
            .environmentObject(Navigation.shared)
    }
    
    func discreteListRowStyle(backgroundColor: Color = Color(uiColor: .systemBackground)) -> some View {
        self.modifier(ClearListRowModifier(backgroundColor: backgroundColor))
    }
}

struct ClearListRowModifier: ViewModifier {
    let backgroundColor: Color
    func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .listRowSpacing(0)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
}
