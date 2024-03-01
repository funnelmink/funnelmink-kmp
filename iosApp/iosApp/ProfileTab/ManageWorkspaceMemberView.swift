//
//  ManageWorkspaceMemberView.swift
//  iosApp
//
//  Created by Jared Warren on 2/29/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Shared
import SwiftUI

struct ManageWorkspaceMemberView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigation: Navigation
    @State var roles: [WorkspaceMembershipRole] = []
    let member: WorkspaceMember
    var body: some View {
        VStack {
            HStack {
                Button("Cancel") {
                    navigation.dismissModal()
                }
                Text(member.username)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                AsyncButton {
                    guard !roles.isEmpty else {
                        Toast.error("You must select at least one role")
                        return
                    }
                    if roles == member.roles {
                        navigation.dismissModal()
                        return
                    }
                    do {
                        let body = WorkspaceMembershipRolesRequest(roles: roles)
                        try await Networking.api.changeWorkspaceRoles(userID: member.userID, body: body)
                        navigation.dismissModal()
                    } catch {
                        Toast.warn(error)
                    }
                } label: {
                    Text("Save")
                }
            }
            List {
                ForEach(WorkspaceMembershipRole.allCases.filter { $0 != .invited }, id: \.self) { role in
                    HStack {
                        Text(role.name)
                        Spacer()
                        if roles.contains(role) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if roles.contains(role) {
                            roles.removeAll(where: { $0 == role })
                        } else {
                            roles.append(role)
                        }
                    }
                }
            }
            if appState.user?.id != member.userID {
                AsyncWarningAlertButton(warningMessage: "Remove \(member.username) from workspace?") {
                    do {
                        try await Networking.api.removeMemberFromWorkspace(userID: member.userID)
                        navigation.dismissModal()
                    } catch {
                        Toast.warn(error)
                    }
                } label: {
                    Text("Remove \(member.username)").foregroundStyle(.red)
                        .padding()
                }
            }
        }
        .padding()
        .loggedOnAppear {
            roles = member.roles
        }
    }
}

#Preview {
    ManageWorkspaceMemberView(member: TestData.workspaceMember)
}
