//
//  JoinExistingWorkspaceView.swift
//  funnelmink
//
//  Created by Jared Warren on 1/1/24.
//  Copyright © 2024 FunnelMink, LLC. All rights reserved.
//

import SwiftUI

struct JoinExistingWorkspaceView: View {
    @EnvironmentObject var navigation: Navigation
    @StateObject var viewModel = JoinExistingWorkspaceViewModel()
    @State var joinWorkspaceName = ""
    var body: some View {
        VStack {
            Spacer()
            Text("Join an existing workspace")
                .font(.largeTitle)
            Text("Enter the workspace's name to request access.")
                .foregroundStyle(.secondary)
            Spacer()
            VStack(spacing: 4) {
                HStack {
                    Text("Workspace name")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                TextField("", text: $joinWorkspaceName, prompt: Text("My company").foregroundColor(.gray))
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
                await viewModel.requestWorkspaceMembership(name: joinWorkspaceName) {
                    navigation.dismissModal()
                }
            } label: {
                Text("Request")
                    .frame(height: 52)
                    .maxReadableWidth()
                    .background(FunnelminkGradient())
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .multilineTextAlignment(.leading)
            Spacer()
        }
        .padding()
        .multilineTextAlignment(.center)
    }
}

#Preview {
    JoinExistingWorkspaceView()
}
