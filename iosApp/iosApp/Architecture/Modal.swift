//
//  Modal.swift
//  iosApp
//
//  Created by Jared Warren on 10/19/23.
//  Copyright © 2023 FunnelMink. All rights reserved.
//

import SwiftUI

enum Modal: Identifiable {
    case any(view: () -> (any View))
    case importContacts
    
    // TODO: don't depend on this viewmodel
    case createTask(TodayViewModel)
    
    // TODO: maybe don't depend on this viewmodel
    case createWorkspace(WorkspacesViewModel)
    case inviteToWorkspace
    case joinExistingWorkspace
    case selectWorkspace
    
    @ViewBuilder
    var view: some View {
        switch self {
        case let .any(view): AnyView(view())
        case .importContacts: ImportContactsView()
            
        case let .createTask(viewModel): CreateTaskView(viewModel: viewModel)
            
        case let .createWorkspace(viewModel): CreateWorkspaceView(viewModel: viewModel)
        case .inviteToWorkspace: WorkspaceInviteView()
        case .joinExistingWorkspace: JoinExistingWorkspaceView()
        case .selectWorkspace: WorkspacesView()
        }
    }
}
