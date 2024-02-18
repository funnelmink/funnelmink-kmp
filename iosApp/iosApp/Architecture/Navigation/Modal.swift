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
    case contactDetails(AccountContact)
    
    case closeRecord(type: FunnelType, id: String)

    case debugMenu
    
    case createCase(accountID: String?)
    case editCase(caseRecord: CaseRecord)
    
    case createLead(accountID: String?)
    
    case editLead(lead: Lead?, funnelID: String?, stageID: String?)
    case convertLead(lead: Lead)
    
    case createOpportunity(accountID: String?)
    case editOpportunity(opportunity: Opportunity)
    
    @ViewBuilder
    var view: some View {
        Group {
            switch self {
            case let .any(view): AnyView(view())
            case .importContacts: ImportContactsView()
            case let .contactDetails(contact): ContactDetailsView(contact: contact)
            case .createTask: EditTaskView()
            case let .editTask(task): EditTaskView(task: task)

            case let .createWorkspace(viewModel): CreateWorkspaceView(viewModel: viewModel)
            case .inviteToWorkspace: WorkspaceInviteView()
            case .joinExistingWorkspace: JoinExistingWorkspaceView()
            case .selectWorkspace: WorkspacesView()
            case .createAccount: CreateAccountView()
            case .createContact: CreateContactView(account: TestData.account)
            case let .closeRecord(type, id): CloseRecordView(recordType: type, recordID: id)
            case .debugMenu: DebugMenu()
                
            case let .createCase(accountID): EditCaseView(accountID: accountID)
            case let .editCase(caseRecord): EditCaseView(caseRecord: caseRecord)
            case .createLead: EditLeadView()
            case let .editLead(lead, funnelID, stageID): EditLeadView(lead: lead, initialFunnelD: funnelID, initialStageID: stageID)
            case let .convertLead(lead): ConvertLeadView(lead: lead)
            case let .createOpportunity(accountID): EditOpportunityView(accountID: accountID)
            case let .editOpportunity(opportunity): EditOpportunityView(opportunity: opportunity)
            }
        }
        .toasted(isPresented: true) // modals exist in a separate window. this modifier lets them display toasts anyways
    }
}
