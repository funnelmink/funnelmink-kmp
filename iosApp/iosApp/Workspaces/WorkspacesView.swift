//
//  WorkspacesView.swift
//  funnelmink
//
//  Created by Jared Warren on 12/28/23.
//  Copyright © 2023 FunnelMink, LLC. All rights reserved.
//

import Shared
import SwiftUI

struct WorkspacesView: View {
    @StateObject var viewModel = WorkspacesViewModel()
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigation: Navigation
    var body: some View {
        VStack {
            Spacer()
            Text("Sign into a workspace")
                .font(.largeTitle)
            Spacer()
            if viewModel.didError {
                Text("Failed to reach the backend. Please check your connection and try again.")
            } else if viewModel.workspaces.isEmpty {
                // TODO: empty state. Has a "try again" button if the connection fails (hopefully never)
                Text("TODO: empty state")
            } else {
                ScrollView {
                    // TODO: this ui is atrocious. Display workspace avatars. Display plan (free, paid) and member count
                    ForEach(viewModel.workspaces, id: \.self) { workspace in
                        workspaceButton(workspace)
                    }
                }
                .scrollIndicators(.never)
                
                Button("Or join an existing workspace") {
                    navigation.presentSheet(.joinExistingWorkspace)
                }
            }
            Spacer()
            if viewModel.didError {
                AsyncButton {
                    await viewModel.fetchWorkspaces()
                } label: {
                    Text("Try again")
                        .frame(height: 52)
                        .maxReadableWidth()
                        .background(LoginBackgroundGradient())
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                Spacer()
            }
        }
        .padding()
        .multilineTextAlignment(.center)
        .task {
            // grab workspaces
            await viewModel.fetchWorkspaces()
            
            // if they don't have any, force them to create one? (TODO: button that lets them to join an existing?)
            if viewModel.workspaces.isEmpty {
                navigation.presentSheet(.createWorkspace(viewModel))
                
                // if they're a member of exactly one workspace, sign them in automatically
            } else if viewModel.workspaces.count == 1,
                      let workspace = viewModel.workspaces.first,
                      [WorkspaceMembershipRole.owner, .member].contains(workspace.role) {
                appState.signIntoWorkspace(workspace)
            }
        }
    }
    
    @ViewBuilder
    func workspaceButton(_ workspace: Workspace) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(workspace.name)
                    .font(.title3)
                if let role = workspace.role {
                    Text(role.name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            switch workspace.role {
            case .owner, .member:
                if workspace.id == appState.workspace?.id {
                    Text("Current")
                        .foregroundColor(.secondary)
                } else {
                    Button {
                        appState.signIntoWorkspace(workspace)
                        navigation.dismissModal()
                    } label: {
                        Text("Sign in")
                    }
                }
            case .requested:
                Text("Request pending")
                    .foregroundColor(.secondary)
            case .invited:
                HStack {
                    WarningAlertButton(warningMessage: "Reject invite?\n\nYou will need another invite in order to join this workspace.") {
                        Task { await viewModel.rejectInvite(workspace.id) { navigation.dismissModal() } }
                    } label: {
                        Text("Reject").foregroundColor(.red)
                    }

                    
                    AsyncButton {
                        await viewModel.acceptInvite(workspace.id) { navigation.dismissModal() }
                    } label: {
                        Text("Accept")
                    }
                }
            case .none:
                EmptyView()
            }
        }
        .maxReadableWidth()
        .frame(height: 52)
        .padding()
        .overlay {
            RoundedRectangle(cornerRadius: 4)
                .stroke(
                    workspace.id == appState.workspace?.id ? Color.purple :
                    [WorkspaceMembershipRole.owner, .member].contains(workspace.role) ? Color.blue : Color.gray,
                    lineWidth: 1
                )
        }
    }
}

#Preview {
    WorkspacesView()
}
