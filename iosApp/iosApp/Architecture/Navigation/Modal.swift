//
//  Modal.swift
//  iosApp
//
//  Created by Jared Warren on 10/19/23.
//  Copyright © 2023 FunnelMink. All rights reserved.
//

import Shared
import SwiftUI

enum Modal: Identifiable {
    case any(view: () -> (any View))
    case importContacts
    
    case createTask
    case editTask(TaskRecord)
    
    // TODO: maybe don't depend on this viewmodel
    case createWorkspace(WorkspacesViewModel)
    case inviteToWorkspace
    case joinExistingWorkspace
    case selectWorkspace
    case createAccount
    case createContact

    case debugMenu
    
    @ViewBuilder
    var view: some View {
        Group {
            switch self {
            case let .any(view): AnyView(view())
            case .importContacts: ImportContactsView()

            case .createTask: EditTaskView()
            case let .editTask(task): EditTaskView(task: task)

            case let .createWorkspace(viewModel): CreateWorkspaceView(viewModel: viewModel)
            case .inviteToWorkspace: WorkspaceInviteView()
            case .joinExistingWorkspace: JoinExistingWorkspaceView()
            case .selectWorkspace: WorkspacesView()
            case .createAccount: CreateAccountView()
            case .createContact: CreateContactView(account: Account(id: "id", address: "street address", city: "City", country: "Country", createdAt: "Date created", email: "email", latitude: 123.123, leadID: "LeadID?", longitude: 123.123, name: "Account Name", notes: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum", phone: "phone number here", state: "STATE", type: .organization, updatedAt: "UpdatedAt?", zip: "Zip Code") )
            case .debugMenu: DebugMenu()
            }
        }
        .toasted(isPresented: true) // modals exist in a separate window. this modifier lets them display toasts anyways
    }
}
