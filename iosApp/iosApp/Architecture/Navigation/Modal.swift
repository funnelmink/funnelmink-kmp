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

    case debugMenu
    
    case createCase
    case createLead
    case editLead(lead: Lead?, funnelID: String?, stageID: String?)
    case createOpportunity
    
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
            case .debugMenu: DebugMenu()
                
            case .createCase: EditCaseView()
            case .createLead: EditLeadView()
            case let .editLead(lead, funnelID, stageID): EditLeadView(lead: lead, initialFunnelD: funnelID, initialStageID: stageID)
            case .createOpportunity: EditOpportunityView()
            }
        }
        .toasted(isPresented: true) // modals exist in a separate window. this modifier lets them display toasts anyways
    }
}
