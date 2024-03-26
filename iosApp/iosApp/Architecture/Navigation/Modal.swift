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
    case selectWorkspace
    case createAccount
    case createContact(accountID: String)
    case contactDetails(AccountContact)
    
    case closeRecord(type: FunnelType, id: String)

    case debugMenu
    
    case createCase(accountID: String)
    case editCase(caseRecord: CaseRecord)
    
    case createLead
    
    case editLead(lead: Lead?)
    case convertLead(lead: Lead)
    
    case createOpportunity(accountID: String?)
    case editOpportunity(opportunity: Opportunity)
    
    case rolePicker(Binding<[WorkspaceMembershipRole]>)
    case manageWorkspaceMember(WorkspaceMember)
    
    case selectAccountAndCreateCase
    case selectAccountAndCreateOpporunity
    case selectAccountAndCreateContact
    
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
            case .selectWorkspace: WorkspacesView()
            case .createAccount: CreateAccountView()
            case let .createContact(accountID): CreateContactView(accountID: accountID)
            case let .closeRecord(type, id): CloseRecordView(recordType: type, recordID: id)
            case .debugMenu: DebugMenu()
                
            case let .createCase(accountID): EditCaseView(accountID: accountID)
            case let .editCase(caseRecord): EditCaseView(caseRecord: caseRecord)
            case .createLead: EditLeadView()
            case let .editLead(lead): EditLeadView(lead: lead)
            case let .convertLead(lead): ConvertLeadView(lead: lead)
            case let .createOpportunity(accountID): EditOpportunityView(accountID: accountID)
            case let .editOpportunity(opportunity): EditOpportunityView(opportunity: opportunity)
            case let .rolePicker(roles): RolePicker(roles: roles)
            case let .manageWorkspaceMember(member): ManageWorkspaceMemberView(member: member)
            case .selectAccountAndCreateCase: SelectAccountView(nextView: { Navigation.shared.modalSheet(.createCase(accountID: $0)) })
            case .selectAccountAndCreateOpporunity: SelectAccountView(nextView: { Navigation.shared.modalSheet(.createOpportunity(accountID: $0)) })
            case .selectAccountAndCreateContact: SelectAccountView(nextView: { Navigation.shared.modalSheet(.createContact(accountID: $0)) })
            }
        }
        .toasted(isPresented: true) // modals exist in a separate window. this modifier lets them display toasts anyways
    }
}
