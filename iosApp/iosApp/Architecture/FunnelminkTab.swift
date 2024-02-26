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

enum FunnelminkTab: Int, Identifiable {
    case today
    case accounts
    case funnels
    case inbox
    case profile
    case pretendLaborTab
    case pretendAdminTab
    case pretendSalesTab
    
    var id: Int { rawValue }
    
    @ViewBuilder
    var root: some View {
        switch self {
        case .today: TodayView()
        case .accounts: AccountsView()
        case .funnels: FunnelsView()
        case .inbox: InboxView()
        case .profile: ProfileView()
        case .pretendAdminTab: Label("Admin (fake)", systemImage: "crown")
        case .pretendLaborTab: Label("Labor (fake)", systemImage: "hammer")
        case .pretendSalesTab: Label("Sales (fake)", systemImage: "lizard")
        }
    }

    @ViewBuilder
    var tabItem: some View {
        switch self {
        case .today: Label("Today", systemImage: "\(String(format: "%02d", Calendar.current.component(.day, from: .init()))).square.fill")
        case .accounts: Label("Accounts", systemImage: "circle.hexagongrid")
        case .funnels: Label("Funnels", image: "funnels.icon")
        case .inbox: Label("Inbox", systemImage: "envelope")
        case .profile: Label("Profile", systemImage: "person")
        case .pretendAdminTab: Label("Admin (fake)", systemImage: "crown")
        case .pretendLaborTab: Label("Labor (fake)", systemImage: "hammer")
        case .pretendSalesTab: Label("Sales (fake)", systemImage: "lizard")
        }
    }
    
    static var activeTabConfiguration: [FunnelminkTab] {
        switch AppState.shared.role {
        case .admin: return adminTabs
        case .labor: return laborTabs
        case .sales: return salesTabs
        default: return adminTabs
        }
    }
    
    static let adminTabs: [FunnelminkTab] = [.today, .pretendAdminTab, .accounts, .funnels, .profile]
    static let laborTabs: [FunnelminkTab] = [.today, .pretendLaborTab, .accounts, .inbox, .profile]
    static let salesTabs: [FunnelminkTab] = [.today, .pretendSalesTab, .accounts, .funnels, .profile]
}
