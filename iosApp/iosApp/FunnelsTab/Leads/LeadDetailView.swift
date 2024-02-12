//
//  LeadDetailView.swift
//  iosApp
//
//  Created by Jared Warren on 2/12/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Shared
import SwiftUI

struct LeadDetailView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigation: Navigation
    @State var lead: Lead
    @State var funnel: Funnel
    @State var stage: FunnelStage
    var body: some View {
        VStack {
            List {
                if lead.email != nil || lead.phone != nil || lead.company != nil || lead.source != nil || lead.jobTitle != nil {
                    Section("CONTACT INFORMATION") {
                        if let email = lead.email {
                            labeledRow(name: "Email", value: email)
                        }
                        if let phone = lead.phone {
                            labeledRow(name: "Phone", value: phone)
                        }
                        if let company = lead.company {
                            labeledRow(name: "Company", value: company)
                        }
                        if let source = lead.source {
                            labeledRow(name: "Source", value: source)
                        }
                        if let jobTitle = lead.jobTitle {
                            labeledRow(name: "Job Title", value: jobTitle)
                        }
                    }
                }
                
                if lead.address != nil || lead.city != nil || lead.state != nil || lead.zip != nil || lead.country != nil {
                    Section("LOCATION INFORMATION") {
                        if let address = lead.address {
                            labeledRow(name: "Address", value: address)
                        }
                        if let city = lead.city {
                            labeledRow(name: "City", value: city)
                        }
                        if let state = lead.state {
                            labeledRow(name: "State", value: state)
                        }
                        if let zip = lead.zip {
                            labeledRow(name: "Zip", value: zip)
                        }
                        if let country = lead.country {
                            labeledRow(name: "Country", value: country)
                        }
                    }
                }
                
                if let latitude = lead.latitude, let longitude = lead.longitude {
                    Section("GEO LOCATION") {
                        labeledRow(name: "Latitude", value: "\(latitude.doubleValue)")
                        labeledRow(name: "Longitude", value: "\(longitude.doubleValue)")
                    }
                }
                
                Section("LEAD MANAGEMENT") {
                    if let assignedTo = lead.assignedTo {
                        labeledRow(name: "Assigned To", value: assignedTo)
                    }
                    // TODO: priority Label
                    labeledRow(name: "Priority", value: "\(lead.priority)")
                    labeledRow(name: "Funnel", value: funnel.name)
                    labeledRow(name: "Stage", value: stage.name)
                }
                
                if let notes = lead.notes {
                    Section("NOTES") {
                        Text(notes)
                    }
                }
            }
            HStack {
                WarningAlertButton(warningMessage: "Are you sure you want to delete this lead?") {
                    Task {
                        do {
                            try await Networking.api.deleteLead(id: lead.id)
                            navigation.popSegue()
                        } catch {
                            Toast.warn(error)
                        }
                    }
                } label: {
                    Text("Delete Lead")
                        .foregroundStyle(.red)
                }
                Spacer()
                Button("Convert or Close Lead") {
                    // TODO: presentation
                    // convert to account
                    // gives the option to also create an opportunity
                    // OR you can close lead
                }
            }
            .padding()
        }
        .navigationTitle(lead.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    navigation.modalSheet(.editLead(lead: lead, funnelID: funnel.id, stageID: stage.id))
                } label: {
                    Text("Edit")
                }
            }
        }
    }
    
    func labeledRow(name: String, value: String) -> some View {
        HStack {
            Text(name)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
    }
}

#Preview {
    LeadDetailView(
        lead: TestData.lead,
        funnel: TestData.leadFunnel,
        stage: TestData.funnelStage0
    )
    .withPreviewDependencies()
}
