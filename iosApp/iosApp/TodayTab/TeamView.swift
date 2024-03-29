//
//  TeamView.swift
//  iosApp
//
//  Created by Jeremy Warren on 3/22/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import SwiftUI
import Shared

struct TeamView: View {
    @EnvironmentObject var nav: Navigation
    @State var members: [WorkspaceMember] = []
    
    var body: some View {
        List {
            allWorkspaceMembers
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                // Your custom leading items here, if any.
            }
            ToolbarItemGroup(placement: .principal) {
                NavigationSearchView()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                // Your custom trailing items here, if any.
            }
        }
        .navigationTitle("Team")
        .loggedTask {
            do {
           let members = try await Networking.api.getWorkspaceMembers()
                self.members = members
            } catch {
                Toast.error(error)
            }
        }
    }
    
    var allWorkspaceMembers: some View {
        ForEach(members, id: \.self) { member in
            Button {
                nav.segue(.memberAssignmentsView(workspaceMember: member))
            } label: {
                CustomCell(title: member.username, cellType: .navigation)
                    .foregroundStyle(Color.primary)
            }

        }
    }

}

#Preview {
    TeamView()
}
