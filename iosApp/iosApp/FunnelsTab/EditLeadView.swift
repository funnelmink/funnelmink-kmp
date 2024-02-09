//
//  EditLeadView.swift
//  iosApp
//
//  Created by Jared Warren on 2/9/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Shared
import SwiftUI

struct EditLeadView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigation: Navigation
    @StateObject var viewModel = EditLeadViewModel()
    
    @State private var address = ""
    @State private var assignedTo = ""
    @State private var city = ""
    @State private var closedDate = ""
    @State private var closedResult: LeadClosedResult?
    @State private var company = ""
    @State private var country = ""
    @State private var createdAt = ""
    @State private var email = ""
    @State private var jobTitle = ""
    @State private var latitude: Double?
    @State private var longitude: Double?
    @State private var name = ""
    @State private var notes = ""
    @State private var phone = ""
    @State private var priority: Int32 = 0
    @State private var source = ""
    @State private var state = ""
    @State private var type: AccountType = .individual
    @State private var updatedAt = ""
    @State private var zip = ""
    
    @State private var funnelID = ""
    @State private var stageID = ""
    
    var lead: Lead?
    
    var body: some View {
        VStack {
            
        }
        .loggedOnAppear {
            if let lead {
                self.address = lead.address ?? ""
                self.assignedTo = lead.assignedTo ?? ""
                self.city = lead.city ?? ""
                self.closedDate = lead.closedDate ?? ""
                self.closedResult = lead.closedResult
                self.company = lead.company ?? ""
                self.country = lead.country ?? ""
                self.createdAt = lead.createdAt
                self.email = lead.email ?? ""
                self.jobTitle = lead.jobTitle ?? ""
                self.latitude = lead.latitude?.doubleValue
                self.longitude = lead.longitude?.doubleValue
                self.name = lead.name
                self.notes = lead.notes ?? ""
                self.phone = lead.phone ?? ""
                self.priority = lead.priority
                self.source = lead.source ?? ""
                self.state = lead.state ?? ""
                self.type = lead.type
                self.updatedAt = lead.updatedAt
                self.zip = lead.zip ?? ""
            }
        }
    }
}

#Preview {
    EditLeadView()
        .withPreviewDependencies()
}

class EditLeadViewModel: ViewModel {
    @Published var state = State()
    
    struct State: Hashable {
    }
}

/*
 Kotlin definition of Lead
 
 @Serializable
 data class Lead(
     val id: String,

     val address: String? = null,
     val assignedTo: String? = null,
     val city: String? = null,
     val closedDate: String? = null,
     val closedResult: LeadClosedResult? = null,
     val company: String? = null,
     val country: String? = null,
     val createdAt: String,
     val email: String? = null,
     val jobTitle: String? = null,
     val latitude: Double? = null,
     val longitude: Double? = null,
     val name: String,
     val notes: String? = null,
     val phone: String? = null,
     val priority: Int,
     val source: String? = null,
     val stage: String? = null,
     val state: String? = null,
     val type: AccountType,
     val updatedAt: String,
     val zip: String? = null,
 )
 */
