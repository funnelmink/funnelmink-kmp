//
//  WorkspaceInviteView.swift
//  funnelmink
//
//  Created by Jared Warren on 12/30/23.
//  Copyright © 2023 FunnelMink, LLC. All rights reserved.
//

import Shared
import SwiftUI

struct WorkspaceInviteView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigation: Navigation
    @StateObject var viewModel = WorkspacesViewModel()
    @State var inviteEmailAddress = ""
    @State var roles = [WorkspaceMembershipRole.admin]
    var body: some View {
        VStack {
            Spacer()
            Text("Invite to \(appState.workspace?.name ?? "workspace")")
                .font(.largeTitle)
            Text("We'll send an email with a link.")
                .foregroundStyle(.secondary)
            Spacer()
            VStack(spacing: 4) {
                HStack {
                    Text("Email address")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                TextField("", text: $inviteEmailAddress, prompt: Text("team.member@mycompany.com").foregroundColor(.gray))
                    .frame(height: 52)
                    .maxReadableWidth()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.black, lineWidth: 0.5))
                    .shadow(radius: 2)
                    .foregroundStyle(.black)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
            }
            .padding(.vertical)
            
            RolePicker(roles: $roles)
            
            AsyncButton {
                guard Validator.isValidEmail(inviteEmailAddress) else {
                    Toast.warn("Please enter a valid email address.")
                    return
                }
                
                guard !roles.isEmpty else {
                    Toast.warn("Please select a role.")
                    return
                }
                
                await viewModel.inviteToWorkspace(email: inviteEmailAddress, roles: roles) {
                    navigation.dismissModal()
                }
            } label: {
                Text("Invite")
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
    WorkspaceInviteView(viewModel: .init())
        .environmentObject(AppState())
}
