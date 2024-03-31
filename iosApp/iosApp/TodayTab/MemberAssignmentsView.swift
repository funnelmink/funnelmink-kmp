//
//  AssignedToMeView.swift
//  iosApp
//
//  Created by Jeremy Warren on 3/22/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import SwiftUI
import Shared


struct MemberAssignmentsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigation: Navigation
    @State var opportunities: [Opportunity] = []
    @State var workspaceMember: WorkspaceMember?
    @State var leads: [Lead] = []
    @State var cases: [CaseRecord] = []
    @State var assignments = MemberAssignments(cases: [], leads: [], opportunities: [], tasks: [])
    
    var body: some View {
        List {
            if !cases.isEmpty {
                Section("Cases") {
                    ForEach(cases, id: \.self) { caseRecord in
                        Button {
                            navigation.segue(.caseDetails(caseRecord: caseRecord))
                        } label: {
                            CustomCell(title: caseRecord.name, cellType: .navigation)
                        }
                    }
                }
            }
            
            if !opportunities.isEmpty {
                Section("Opportunities") {
                    ForEach(opportunities, id: \.self) { opportunity in
                        Button {
                            navigation.segue(.opportunityDetails(opportunity: opportunity))
                        } label: {
                            CustomCell(title: opportunity.name, cellType: .navigation)
                        }
                    }
                }
            }
            
            if !leads.isEmpty {
                Section("Leads") {
                    ForEach(leads, id: \.self) { lead in
                        Button {
                            navigation.segue(.leadDetails(lead: lead))
                        } label: {
                            CustomCell(title: lead.name, cellType: .navigation)
                        }
                    }
                }
            }
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
        
        .navigationTitle("@\(workspaceMember?.username ?? "Me")")
        .loggedTask {
            do {
                // Use the passed in WorkspaceMember. If no member, use "Me" id
                guard let id = appState.workspace?.memberID else { return }
                assignments = try await Networking.api.getAssignments(memberID: id)
            } catch {
                Toast.error(error)
            }
        }
        
    }
}

#Preview {
    MemberAssignmentsView()
}
