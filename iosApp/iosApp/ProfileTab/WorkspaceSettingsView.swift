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
                        memberCell(member)
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
                        navigation.modalSheet(.inviteToWorkspace) {
                            Task { await viewModel.fetchWorkspaceMembers() }
                        }
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
    
    private func memberCell(_ member: WorkspaceMember) -> some View {
        HStack {
            //            if let image = image {
            //                image
            //                    .resizable()
            //                    .frame(width: 40, height: 40)
            //                    .clipShape(Circle())
            //            } else {
            Circle()
                .fill(Color.gray)
                .frame(width: 40, height: 40)
                .overlay(Text(member.username.prefix(1)).foregroundStyle(.white))
            //            }
            Text(member.username).fontWeight(.medium)
            Spacer()
            if member.roles.contains(.invited) {
                Text("Invited")
                    .foregroundStyle(.secondary)
            } else if appState.roles.contains(.admin) {
                Button {
                    navigation.modalSheet(.manageWorkspaceMember(member)) {
                        Task {
                            await viewModel.fetchWorkspaceMembers()
                            if member.userID == appState.user?.id {
                                appState.workspace?.roles = viewModel.workspaceMembers.first(where: { $0.userID == appState.user?.id })?.roles ?? []
                            }
                        }
                    }
                } label: {
                    Text(member.roles.map(\.name).joined(separator: ", "))
                }
            } else {
                Text(member.roles.map(\.name).joined(separator: ", "))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    WorkspaceSettingsView()
        .environmentObject(AppState())
}
