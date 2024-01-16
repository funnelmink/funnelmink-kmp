//
//  Segue.swift
//  iosApp
//
//  Created by Jared Warren on 10/19/23.
//  Copyright © 2023 FunnelMink, LLC. All rights reserved.
//

import SwiftUI
import Shared

enum Segue: NavigationSegue {
    case home
    case contacts
    case workspaceSettings
    case contactView(Contact)
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .home: Text("HOME")
        case .contacts: ContactsView()
        case .workspaceSettings: WorkspaceSettingsView()
        case let .contactView(contact): ContactView(contact: contact)
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
