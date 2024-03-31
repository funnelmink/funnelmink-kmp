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
                if !lead.email.isEmpty || !lead.phone.isEmpty || !lead.company.isEmpty || !lead.source.isEmpty || !lead.jobTitle.isEmpty {
                    Section("CONTACT INFORMATION") {
                        if !lead.email.isEmpty {
                            LabeledRow(name: "Email", value: lead.email)
                        }
                        if !lead.phone.isEmpty {
                            LabeledRow(name: "Phone", value: lead.phone)
                        }
                        if !lead.company.isEmpty {
                            LabeledRow(name: "Company", value: lead.company)
                        }
                        if !lead.source.isEmpty {
                            LabeledRow(name: "Source", value: lead.source)
                        }
                        if !lead.jobTitle.isEmpty {
                            LabeledRow(name: "Job Title", value: lead.jobTitle)
                        }
                    }
                }
                
                if !lead.address.isEmpty || !lead.city.isEmpty || !lead.state.isEmpty || !lead.zip.isEmpty || !lead.country.isEmpty {
                    Section("LOCATION INFORMATION") {
                        if !lead.address.isEmpty {
                            LabeledRow(name: "Address", value: lead.address)
                        }
                        if !lead.city.isEmpty {
                            LabeledRow(name: "City", value: lead.city)
                        }
                        if !lead.state.isEmpty {
                            LabeledRow(name: "State", value: lead.state)
                        }
                        if !lead.zip.isEmpty {
                            LabeledRow(name: "Zip", value: lead.zip)
                        }
                        if !lead.country.isEmpty {
                            LabeledRow(name: "Country", value: lead.country)
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
                    if let assignedTo = lead.assignedToName {
                        LabeledRow(name: "Assigned To", value: assignedTo)
                    }
                    LabeledRow(
                        name: "Priority",
                        value: lead.priority.priorityName,
                        imageName: lead.priority.priorityIconName,
                        valueColor: lead.priority.priorityColor
                    )
                }
                
                if !lead.notes.isEmpty {
                    Section("NOTES") {
                        Text(lead.notes)
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
                    navigation.modalSheet(.editLead(lead: lead), onDismiss: refreshLead)
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
        lead: TestData.lead
    )
    .withPreviewDependencies()
}
