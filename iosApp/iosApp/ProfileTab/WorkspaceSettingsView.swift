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
    @State var newRoles: [WorkspaceMembershipRole] = []
    @ViewBuilder
    var body: some View {
        if let workspace = appState.workspace {
            List {
                Section("MEMBERS") {
                    ForEach(viewModel.workspaceMembers, id: \.self) { member in
                        memberCell(id: member.userID, name: member.username, roles: member.roles, image: nil)
                    }
                }
                if appState.roles.contains(.admin) {
                    Section("WORKSPACE NAME") {
                        HStack {
                            TextField("Workspace name", text: $newWorkspaceName)
                                .keyboardType(.alphabet)
                                .autocorrectionDisabled()
                                .textContentType(.organizationName)
                            if newWorkspaceName != workspace.name {
                                AsyncButton {
                                    await viewModel.updateWorkspace(name: newWorkspaceName)
                                } label: {
                                    Text("Save")
                                }
                            }
                        }
                    }
                }
                Section("DANGER ZONE") {
                    Button("Invite new members") {
                        navigation.modalSheet(.inviteToWorkspace)
                    }
                    
                    Button("Upgrade to premium") {
                        Toast.error("TODO")
                        //                        navigation.externalDeeplink(to: .funnelminkStripe)
                    }
                    
                    
                    WarningAlertButton(warningMessage: "Leave workspace?\n\nYou will need an invite to rejoin.") {
                        Task { await viewModel.leaveWorkspace() }
                    } label: {
                        Text("Leave workspace")
                    }
                    
                    WarningAlertButton(warningMessage: "Delete workspace?\n\nThis action cannot be undone.") {
                        Task { await viewModel.deleteWorkspace() }
                    } label: {
                        Text("Delete workspace").foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(workspace.name)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        navigation.modalSheet(.selectWorkspace)
                    } label: {
                        Text("Change workspace")
                    }
                }
            }
            .loggedTask {
                await viewModel.onAppear()
                newWorkspaceName = workspace.name
            }
        } else {
            Color.primary.onAppear { navigation.popSegue() }
        }
    }
    
    private func memberCell(id: String?, name: String, roles: [WorkspaceMembershipRole], image: Image?) -> some View {
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
            if roles.contains(.invited) {
                Text("Invited")
                    .foregroundStyle(.secondary)
            } else if roles.contains(.requested) && appState.roles.contains(.admin), let id {
                VStack {
                    AsyncButton {
                        await viewModel.declineWorkspaceRequest(userID: id)
                    } label: {
                        Text("Reject")
                    }
                    Button {
                        navigation.modalSheet(.rolePicker($newRoles)) {
                            newRoles = [.admin]
                            Task { await viewModel.acceptWorkspaceRequest(userID: id, roles: newRoles) }
                        }
                    } label: {
                        Text("Approve")
                    }
                }
            } else if roles.contains(.requested) {
                Text("Requesting to join")
                    .foregroundStyle(.secondary)
            } else if appState.roles.contains(.admin), let id {
                Button {
                    newRoles = roles
                    navigation.modalSheet(.rolePicker($newRoles)) {
                        Task { await viewModel.changeMemberRoles(id: id, to: newRoles) }
                    }
                } label: {
                    Text(roles.map(\.name).joined(separator: ", "))
                }
                if appState.user?.id != id {
                    WarningAlertButton(warningMessage: "Remove \(name) from workspace?") {
                        Task { await viewModel.removeMemberFromWorkspace(id: id) }
                    } label: {
                        Text("Remove").foregroundStyle(.red)
                    }
                }
            } else {
                Text(roles.map(\.name).joined(separator: ", "))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    WorkspaceSettingsView()
        .environmentObject(AppState())
}
