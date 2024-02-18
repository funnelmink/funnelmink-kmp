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
    var closedPrompt: String? {
        var out = ""
        switch lead.closedResult {
        case .lost: out = "This Lead was closed as `Lost`"
        case .account: out = "This Lead was converted to an Account"
        case .accountAndOpportunity: out = "This Lead was converted to an Account + Opportunity"
        case .none: return nil
        }
        if let closedDate = lead.closedDate?.toDate()?.toTaskSectionTitle() {
            out += " on \(closedDate)"
        }
        return out
    }
    var body: some View {
        VStack {
            if let closedPrompt {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.yellow)
                    .overlay {
                        Text(closedPrompt)
                            .foregroundStyle(.secondary)
                            .padding()
                    }
                    .frame(height: 100)
                    .padding()
            }
            List {
                if lead.email != nil || lead.phone != nil || lead.company != nil || lead.source != nil || lead.jobTitle != nil {
                    Section("CONTACT INFORMATION") {
                        if let email = lead.email {
                            LabeledRow(name: "Email", value: email)
                        }
                        if let phone = lead.phone {
                            LabeledRow(name: "Phone", value: phone)
                        }
                        if let company = lead.company {
                            LabeledRow(name: "Company", value: company)
                        }
                        if let source = lead.source {
                            LabeledRow(name: "Source", value: source)
                        }
                        if let jobTitle = lead.jobTitle {
                            LabeledRow(name: "Job Title", value: jobTitle)
                        }
                    }
                }
                
                if lead.address != nil || lead.city != nil || lead.state != nil || lead.zip != nil || lead.country != nil {
                    Section("LOCATION INFORMATION") {
                        if let address = lead.address {
                            LabeledRow(name: "Address", value: address)
                        }
                        if let city = lead.city {
                            LabeledRow(name: "City", value: city)
                        }
                        if let state = lead.state {
                            LabeledRow(name: "State", value: state)
                        }
                        if let zip = lead.zip {
                            LabeledRow(name: "Zip", value: zip)
                        }
                        if let country = lead.country {
                            LabeledRow(name: "Country", value: country)
                        }
                    }
                }
                
                if let latitude = lead.latitude, let longitude = lead.longitude {
                    Section("GEO LOCATION") {
                        LabeledRow(name: "Latitude", value: "\(latitude.doubleValue)")
                        LabeledRow(name: "Longitude", value: "\(longitude.doubleValue)")
                    }
                }
                
                Section("LEAD MANAGEMENT") {
                    if let assignedTo = lead.assignedTo {
                        LabeledRow(name: "Assigned To", value: assignedTo)
                    }
                    LabeledRow(
                        name: "Priority",
                        value: lead.priority.priorityName,
                        imageName: lead.priority.priorityIconName,
                        valueColor: lead.priority.priorityColor
                    )
                    LabeledRow(name: "Funnel", value: funnel.name)
                    LabeledRow(name: "Stage", value: stage.name)
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
                    navigation.modalSheet(.convertLead(lead: lead), onDismiss: refreshLead)
                }
            }
            .padding()
        }
        .navigationTitle(lead.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    navigation.modalSheet(.editLead(lead: lead, funnelID: funnel.id, stageID: stage.id), onDismiss: refreshLead)
                } label: {
                    Text("Edit")
                }
            }
        }
        .logged(info: lead.id)
    }
    
    private func refreshLead() {
        Task { @MainActor in
            lead = try await Networking.api.getLead(id: lead.id)
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
