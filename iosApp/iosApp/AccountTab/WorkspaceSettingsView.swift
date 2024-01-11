//
//  WorkspaceSettingsView.swift
//  funnelmink
//
//  Created by Jared Warren on 12/29/23.
//  Copyright © 2023 FunnelMink, LLC. All rights reserved.
//

import Shared
import SwiftUI

struct WorkspaceSettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigation: Navigation
    @StateObject var viewModel = WorkspaceSettingsViewModel()
    @State var newWorkspaceName = ""
    @ViewBuilder
    var body: some View {
        if let workspace = appState.workspace {
            List {
                Section("MEMBERS") {
                    ForEach(viewModel.workspaceMembers, id: \.self) { member in
                        memberCell(id: member.userID, name: member.username, role: member.role, image: nil)
                    }
                }
                Section("WORKSPACE NAME") {
                    if appState.isWorkspaceOwner {
                        TextField("Workspace name", text: $newWorkspaceName)
                            .keyboardType(.alphabet)
                            .autocorrectionDisabled()
                            .textContentType(.organizationName)
                    }
                }
                Section("DANGER ZONE") {
                    Button("Invite new members") {
                        navigation.presentSheet(.inviteToWorkspace)
                    }
                    
                    Button("Upgrade to premium") {
                        appState.todo()
//                        navigation.externalDeeplink(to: .funnelminkStripe)
                    }
                    
                    
                    WarningAlertButton(warningMessage: "Leave workspace?\n\nYou will need an invite to rejoin.") {
                        Task { await viewModel.leaveWorkspace() }
                    } label: {
                        Text("Leave workspace").foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(workspace.name)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        navigation.presentSheet(.selectWorkspace)
                    } label: {
                        Text("Change workspace")
                    }
                }
            }
            .task {
                await viewModel.onAppear()
                newWorkspaceName = workspace.name
            }
        } else {
            Color.primary.onAppear { navigation.popSegue() }
        }
    }
    
    private func memberCell(id: String, name: String, role: WorkspaceMembershipRole, image: Image?) -> some View {
        HStack {
            if let image = image {
                image
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 40, height: 40)
                    .overlay(Text(name.prefix(1)).foregroundStyle(.white))
            }
            Text(name).fontWeight(.medium)
            Spacer()
            if role == .invited {
                Text("Invited")
                    .foregroundStyle(.secondary)
            } else if role == .requested && appState.isWorkspaceOwner {
                VStack {
                    AsyncButton {
                        await viewModel.acceptWorkspaceRequest(userID: id)
                    } label: {
                        Text("Reject")
                    }
                    AsyncButton {
                        await viewModel.acceptWorkspaceRequest(userID: id)
                    } label: {
                        Text("Approve")
                    }
                }
            } else if role == .requested {
                Text("Requesting to join")
                    .foregroundStyle(.secondary)
            } else if appState.isWorkspaceOwner {
                Picker(
                    "",
                    selection: Binding(
                        get: { role },
                        set: { viewModel.changeMemberRole(id: id, to: $0) }
                    )
                ) {
                    Text("Owner").tag(WorkspaceMembershipRole.owner)
                    Text("Member").tag(WorkspaceMembershipRole.member)
                    if appState.user?.uid != id {
                        WarningAlertButton(warningMessage: "Remove \(name) from workspace?") {
                            Task { await viewModel.removeMemberFromWorkspace(id: id) }
                        } label: {
                            Text("Remove").foregroundStyle(.red)
                        }
                    }
                }
            } else {
                Text(role.name)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    WorkspaceSettingsView()
        .environmentObject(AppState())
}
