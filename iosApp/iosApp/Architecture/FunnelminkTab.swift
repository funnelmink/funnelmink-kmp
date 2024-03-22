//
//  FunnelminkTab.swift
//  iosApp
//
//  Created by Jared Warren on 2/26/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation
import Shared
import SwiftUI

enum FunnelminkTab: Int, Identifiable, CaseIterable {
    // the `case` order is how they'll appear on the TabView. Feel free to rearrange.
    case dashboard
    case assignedToMe
    case accounts
    case leads
    case team
    case cases
    case inbox
    case opportunities
    case tasks
    case settings
    
    var id: Int { rawValue }
    
    @ViewBuilder
    var root: some View {
        switch self {
        case .dashboard: TasksView()
        case .assignedToMe: AssignedToMeView()
        case .accounts: AccountsView()
        case .leads: LeadsView()
        case .team: TeamView()
        case .cases: Label("Cases", systemImage: "briefcase")
        case .inbox: InboxView()
        case .opportunities: Label("Opportunities", systemImage: "star")
        case .tasks: TasksView()
        case .settings: SettingsView()
        }
    }
    
    @ViewBuilder
    var tabItem: some View {
        switch self {
        case .dashboard: Label("Today", systemImage: "\(String(format: "%02d", Calendar.current.component(.day, from: .init()))).square.fill")
        case .assignedToMe: Label("Me", systemImage: "at")
        case .accounts: Label("Accounts", systemImage: "circle.hexagongrid")
        case .leads: Label("Leads", systemImage: "point.3.connected.trianglepath.dotted")
        case .team: Label("Team", systemImage: "person.3")
        case .inbox: Label("Inbox", systemImage: "envelope")
        case .cases: Label("Cases", systemImage: "wrench.and.screwdriver")
        case .opportunities: Label("Opportunities", systemImage: "trophy")
        case .tasks: Label("Tasks", systemImage: "checkmark.circle")
        case .settings: Label("Settings", systemImage: "gearshape")
        }
    }
    
    static var activeTabConfiguration: [FunnelminkTab] {
        allCases.filter { $0.hasAccess(AppState.shared.roles) }
    }
}

private extension FunnelminkTab {
    func hasAccess(_ roles: [WorkspaceMembershipRole]) -> Bool {
        var required = Set<WorkspaceMembershipRole>()
        
        // right now these are just sort of random placeholders
        switch self {
        case .dashboard: required = [.admin, .sales, .labor]
        case .assignedToMe: required = [.admin, .sales, .labor]
        case .accounts: required = [.admin, .sales, .labor]
        case .leads: required = [.admin, .sales, .labor]
        case .team: required = [.admin, .labor, .sales]
        case .cases: required = []
        case .inbox: required = []
        case .opportunities: required = []
        case .settings: required = []
        case .tasks: required = []
        }
        
        return !required.isDisjoint(with: roles)
    }
}
