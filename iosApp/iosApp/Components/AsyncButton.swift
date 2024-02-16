//
//  AsyncButton.swift
//  funnelmink
//
//  Created by Jared Warren on 12/23/23.
//  Copyright © 2023 FunnelMink, LLC. All rights reserved.
//

import SwiftUI

/// A `Task` button that can be pressed multiple times, but only executes the action once at a time.
struct AsyncButton<Label: View>: View {
    @State private var isActing = false
    let action: () async throws -> Void
    @ViewBuilder var label: () -> Label
    var onFail: ((Error) -> Void)?
    var body: some View {
        Button {
            guard !isActing else { return }
            Task { @MainActor in
                isActing = true
                do {
                    try await action()
                } catch {
                    onFail?(error)
                }
                isActing = false
            }
        } label: {
            label()
        }
    }
}

#Preview {
    VStack {
        AsyncButton {
            // try await viewModel.someAsyncRequest()
        } label: {
            // whatever label
        } onFail: { _ in
            // optional. roll back to the previous state (if we updated optimistically)
        }
    }
}
