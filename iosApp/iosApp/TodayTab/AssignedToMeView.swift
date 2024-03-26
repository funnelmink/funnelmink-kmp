//
//  AssignedToMeView.swift
//  iosApp
//
//  Created by Jeremy Warren on 3/22/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import SwiftUI
import Shared

struct AssignedToMeView: View {
    @EnvironmentObject var navigation: Navigation
    @State var opportunities: [Opportunity] = []
    @State var leads: [Lead] = []
    @State var cases: [CaseRecord] = []
    
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
        .loggedTask {
            do {
//               let searchResults = try await Networking.api.getAssignments(memberID: "1")
//                self.searchResults = searchResults
            } catch {
                Toast.error(error)
            }
        }
        
    }
}

#Preview {
    AssignedToMeView()
}
