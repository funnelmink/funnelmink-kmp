//
//  LeadsView.swift
//  iosApp
//
//  Created by Jeremy Warren on 3/22/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import SwiftUI
import Shared

struct LeadsView: View {
    @EnvironmentObject var nav: Navigation
    @State var leads: [Lead] = []
    
    var body: some View {
        List {
            allLeads
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
        .navigationTitle("Leads")
        .loggedTask {
            do {
           let leads = try await Networking.api.getLeads()
                self.leads = leads
            } catch {
                Toast.error(error)
            }
        }
    }
    
    var allLeads: some View {
        ForEach(leads, id: \.self) { lead in
            Button {
                nav.segue(.leadDetails(lead: lead))
            } label: {
                CustomCell(title: lead.name, cellType: .navigation)
                    .foregroundStyle(Color.primary)
            }

        }
    }
}

#Preview {
    LeadsView()
}
