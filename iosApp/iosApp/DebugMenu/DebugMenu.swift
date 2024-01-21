//
//  DebugMenu.swift
//  iosApp
//
//  Created by Jared Warren on 1/18/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Shared
import SwiftUI

/// Gives developer accounts superpowers.
struct DebugMenu: View {
    @EnvironmentObject var navigation: Navigation
    @State private var selection: Selection = .debugMenu
    // Select between viewing the logs or the feature flags.
    
    @ViewBuilder
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                HStack {
                    backButton
                    Spacer()
                    Text(selection.rawValue)
                        .font(.title)
                    Spacer()
                    backButton.hidden()
                }
                .padding(.horizontal)
                switch selection {
                case .logs: LogsView()
                case .featureFlags: FeatureFlagsView()
                case .debugMenu:
                    ScrollView {
                        menuButton(title: "Logs", selection: .logs)
                            .padding(.top)
                        menuButton(title: "Feature Flags", selection: .featureFlags)
                    }
                }
            }
        }
        .foregroundStyle(.white)
    }
    
    @ViewBuilder
    var backButton: some View {
        if selection == .debugMenu {
            Button("Close") {
                navigation.dismissModal()
            }
        } else {
            Button("Back") {
                selection = .debugMenu
            }
        }
    }
    
    func menuButton(title: String, selection: Selection) -> some View {
        Button {
            self.selection = selection
        } label: {
            Text(title)
                .padding()
                .maxReadableWidth()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white, lineWidth: 1)
                )
        }
        .padding(.horizontal, 2)
    }
    
    enum Selection: String, Identifiable {
        case logs = "Logs"
        case featureFlags = "Feature Flags"
        case debugMenu = "Debug Menu"
        var id: String { rawValue }
    }
}

#Preview {
    DebugMenu()
}
