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
    case accounts
    case cases
    case inbox
    case leads
    case opportunities
    case tasks
    case settings
    
    var id: Int { rawValue }
    
    @ViewBuilder
    var root: some View {
        switch self {
        case .dashboard: TasksView()
        case .accounts: AccountsView()
        case .cases: Label("Cases", systemImage: "briefcase")
        case .inbox: InboxView()
        case .leads: Label("Leads", systemImage: "person.3")
        case .opportunities: Label("Opportunities", systemImage: "star")
        case .tasks: TasksView()
        case .settings: SettingsView()
        }
    }
    
    @ViewBuilder
    var tabItem: some View {
        switch self {
        case .dashboard: Label("Today", systemImage: "\(String(format: "%02d", Calendar.current.component(.day, from: .init()))).square.fill")
        case .accounts: Label("Accounts", systemImage: "circle.hexagongrid")
        case .cases: Label("Cases", systemImage: "wrench.and.screwdriver")
        case .inbox: Label("Inbox", systemImage: "envelope")
        case .leads: Label("Leads", systemImage: "point.3.connected.trianglepath.dotted")
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
        case .accounts: required = [.admin, .sales, .labor]
        case .cases: required = [.admin, .labor]
        case .dashboard: required = []
        case .inbox: required = []
        case .leads: required = [.admin, .sales]
        case .opportunities: required = [.admin, .sales]
        case .settings: required = [.admin, .labor, .sales]
        case .tasks: required = [.admin, .labor, .sales]
        }
        
        return !required.isDisjoint(with: roles)
    }
}
