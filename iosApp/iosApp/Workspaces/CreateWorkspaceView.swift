//
//  CreateWorkspaceView.swift
//  funnelmink
//
//  Created by Jared Warren on 12/23/23.
//  Copyright © 2023 FunnelMink, LLC. All rights reserved.
//

import SwiftUI

struct CreateWorkspaceView: View {
    @ObservedObject var viewModel: WorkspacesViewModel
    @EnvironmentObject var navigation: Navigation
    @State var createWorkspaceName = ""
    
    var body: some View {
        VStack {
            Spacer()
            Text("Create your workspace")
                .font(.largeTitle)
            Text("Usually named after your organization, team or company.")
                .foregroundStyle(.secondary)
            Color // use Color.clear instead of Spacer on this view because they're allowed to have overlays
                .clear
                .overlay {
                    if let errorMessage = viewModel.creationErrorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            VStack(spacing: 4) {
                HStack {
                    Text("Workspace name")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                TextField("", text: $createWorkspaceName, prompt: Text("My company").foregroundColor(.gray))
                    .frame(height: 52)
                    .maxReadableWidth()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.black, lineWidth: 0.5))
                    .shadow(radius: 2)
                    .foregroundStyle(.black)
                    .keyboardType(.alphabet)
                    .autocorrectionDisabled()
                    .textContentType(.organizationName)
            }
            .padding(.vertical)
            AsyncButton {
                await viewModel.createWorkspace(name: createWorkspaceName) {
                    navigation.dismissModal()
                }
            } label: {
                Text("Create")
                    .frame(height: 52)
                    .maxReadableWidth()
                    .background(LoginBackgroundGradient())
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .multilineTextAlignment(.leading)
            Color.clear
        }
        .padding()
        .multilineTextAlignment(.center)
    }
}

#Preview {
    CreateWorkspaceView(viewModel: .init())
}
