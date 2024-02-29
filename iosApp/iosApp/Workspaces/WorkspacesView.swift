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
            Text("Sign into a workspace")
                .font(.largeTitle)
            Spacer()
            if viewModel.didError {
                Text("Something went wrong")
                AsyncButton {
                    await viewModel.fetchWorkspaces()
                } label: {
                    Text("Try again")
                        .frame(height: 52)
                        .maxReadableWidth()
                        .background(FunnelminkGradient())
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            } else if viewModel.workspaces.isEmpty {
                Text("You're not in a workspace yet")
            } else {
                ScrollView {
                    ForEach(viewModel.workspaces, id: \.self) { workspace in
                        workspaceButton(workspace)
                    }
                }
                .scrollIndicators(.never)
            }
            Spacer()
            otherOptions
        }
        .padding()
        .multilineTextAlignment(.center)
        .loggedTask {
            // grab workspaces
            await viewModel.fetchWorkspaces()
            
            // if they don't have any, force them to create one? (TODO: button that lets them to join an existing?)
            if viewModel.workspaces.isEmpty && !viewModel.didError {
                navigation.modalSheet(.createWorkspace(viewModel))
                
                // if they're a member of exactly one workspace, sign them in automatically
            } else if viewModel.workspaces.count == 1,
                      let workspace = viewModel.workspaces.first,
                      // `!isDisjoint` means the sets overlap (workspace.roles contains admin, sales or labor)
                      !Set([WorkspaceMembershipRole.admin, .sales, .labor]).isDisjoint(with: workspace.roles) {
                appState.signIntoWorkspace(workspace)
            }
        }
    }
    
    // TODO: Display workspace avatars. Display plan (free, paid) and member count
    @ViewBuilder
    func workspaceButton(_ workspace: Workspace) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(workspace.name)
                    .font(.title3)
                Text(workspace.roles.map(\.name).joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            
            if workspace.roles.contains(.invited) {
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
            } else if workspace.id == appState.workspace?.id {
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
        }
        .maxReadableWidth()
        .frame(height: 52)
        .padding()
        .overlay {
            RoundedRectangle(cornerRadius: 4)
                .stroke(
                    workspace.id == appState.workspace?.id ? Color.purple :
                        Set([WorkspaceMembershipRole.admin, .sales, .labor]).isDisjoint(with: workspace.roles) ? Color.gray : Color.blue,
                    lineWidth: 1
                )
        }
    }
    
    @ViewBuilder
    var otherOptions: some View {
        VStack {
            if viewModel.workspaces.isEmpty {
                Button("Create a new workspace") {
                    navigation.modalSheet(.createWorkspace(viewModel))
                }
                Text("or")
                Button("Sign into a different account") {
                    appState.signOut()
                }
            } else {
                Text("You can also")
                Button("Create a new workspace") {
                    navigation.modalSheet(.createWorkspace(viewModel))
                }
            }
        }
    }
}

#Preview {
    WorkspacesView().withPreviewDependencies()
}
