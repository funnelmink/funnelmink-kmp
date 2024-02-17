//
//  WarningAlertButton.swift
//  funnelmink
//
//  Created by Jared Warren on 12/30/23.
//  Copyright © 2023 FunnelMink, LLC. All rights reserved.
//

import SwiftUI

struct WarningAlertButton<Label: View>: View {
    @State private var isPresenting = false
    let warningMessage: String
    var confirmationText = "Continue"
    let action: () -> Void
    @ViewBuilder var label: Label
    var body: some View {
        Button {
            isPresenting = true
        } label: {
            label
        }
        .alert(isPresented: $isPresenting) {
            Alert(title: Text(warningMessage),
                  primaryButton: .cancel(),
                  secondaryButton: .destructive(Text(confirmationText), action: {
                action()
            }))
        }
    }
}

struct AsyncWarningAlertButton<Label: View>: View {
    @State private var isPresenting = false
    let warningMessage: String
    var confirmationText = "Continue"
    let action: () async -> Void
    @ViewBuilder var label: Label
    var body: some View {
        Button {
            isPresenting = true
        } label: {
            label
        }
        .alert(isPresented: $isPresenting) {
            Alert(title: Text(warningMessage),
                  primaryButton: .cancel(),
                  secondaryButton: .destructive(Text(confirmationText), action: {
                Task { @MainActor in
                    await action()
                }
            }))
        }
    }
}

#Preview {
    WarningAlertButton(warningMessage: "Are you sure you want to delete this workspace?", action: {}) {
        Text("Delete workspace")
    }
}
