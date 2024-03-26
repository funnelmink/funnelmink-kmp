//
//  Segue.swift
//  iosApp
//
//  Created by Jared Warren on 10/19/23.
//  Copyright © 2023 FunnelMink, LLC. All rights reserved.
//

import Shared
import SwiftUI
import Shared

enum Segue: NavigationSegue {
    case home
    case accounts
    
    case taskDetails(TaskRecord)
    
    case workspaceSettings
    case accountView(Account)
    
    case searchResultList
    case caseDetails(caseRecord: CaseRecord, funnel: Funnel, stage: FunnelStage)
    case leadDetails(lead: Lead)
    case opportunityDetails(opportunity: Opportunity, funnel: Funnel, stage: FunnelStage)
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .home: Text("HOME")
        case .accounts: AccountsView()
        case let .taskDetails(task): TaskDetailView(task: task)
        case .workspaceSettings: WorkspaceSettingsView()
        case let .accountView(account): AccountView(contacts: [], account: account)
        case let .caseDetails(caseRecord, funnel, stage): CaseDetailView(caseRecord: caseRecord, funnel: funnel, stage: stage)
        case let .leadDetails(lead): LeadDetailView(lead: lead)
        case let .opportunityDetails(opportunity, funnel, stage): OpportunityDetailView(opportunity: opportunity, funnel: funnel, stage: stage)
        case .searchResultList: SearchResultList()
        }
    }
}

enum UnauthenticatedSegue: NavigationSegue {
    case login
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .login: LoginView()
        }
    }
}
