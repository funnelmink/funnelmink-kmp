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
    
    @State private var shouldDisplayRequiredIndicators = false
    
    var lead: Lead?
    var initialFunnelD: String?
    var initialStageID: String?
    
    var body: some View {
        VStack {
            List {
                Text(lead == nil ? "New Lead" : "Edit Lead")
                    .fontWeight(.bold)
                    .discreteListRowStyle(backgroundColor: .clear)
                    .frame(height: 1)
                Section {
                    CustomTextField(
                        text: $name,
                        placeholder: "Name",
                        style: .text
                    )
                    .autocorrectionDisabled()
                    .discreteListRowStyle()
                    .requiredIndicator(isVisible: shouldDisplayRequiredIndicators)
                }
                
                Section("CONTACT INFORMATION") {
                    CustomTextField(text: $email, placeholder: "Email", style: .email)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .discreteListRowStyle()
                    CustomTextField(text: $phone, placeholder: "Phone", style: .phone)
                        .onChange(of: phone) { newValue in
                            phone = newValue.toPhoneNumber()
                        }
                        .discreteListRowStyle()
                    CustomTextField(text: $company, placeholder: "Company", style: .text)
                        .autocorrectionDisabled()
                        .discreteListRowStyle()
                    CustomTextField(text: $source, placeholder: "Source", style: .text)
                        .autocorrectionDisabled()
                        .discreteListRowStyle()
                    
                    // TODO: accounttype toggle
                }
                
                Section("LOCATION INFORMATION") {
                    CustomTextField(text: $address, placeholder: "Address", style: .text)
                        .autocorrectionDisabled()
                        .discreteListRowStyle()
                    CustomTextField(text: $city, placeholder: "City", style: .text)
                        .autocorrectionDisabled()
                        .discreteListRowStyle()
                    CustomTextField(text: $state, placeholder: "State", style: .text)
                        .autocorrectionDisabled()
                        .discreteListRowStyle()
                    CustomTextField(text: $zip, placeholder: "Zip", style: .decimal)
                        .autocorrectionDisabled()
                        .discreteListRowStyle()
                    CustomTextField(text: $country, placeholder: "Country", style: .text)
                        .autocorrectionDisabled()
                        .discreteListRowStyle()
                }
                
                // TODO: lat/lon fields and a button that offers to fill them in based on the address
                
                // TODO: priority (look at task view)
                
                Section("JOB INFORMATION") {
                    CustomTextField(text: $jobTitle, placeholder: "Job Title", style: .text)
                        .autocorrectionDisabled()
                        .discreteListRowStyle()
                }
                
                // TODO: funnelID, stageID and assignedTo
                Section("LEAD MANAGEMENT") {
                    CustomTextField(text: $assignedTo, placeholder: "Assigned To", style: .text)
                        .autocorrectionDisabled()
                        .discreteListRowStyle()
                }
                // TODO: add a way to dismiss the keyboard
                
                Section("NOTES") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke()
                                .foregroundStyle(.gray).opacity(0.4)
                        }
                        .padding(4)
                        .discreteListRowStyle()
                }
            }
            AsyncButton {
                do {
                    if let lead {
                        try await viewModel.updateLead(
                            leadID: lead.id,
                            name: name,
                            email: email,
                            phone: phone,
                            company: company,
                            source: source,
                            address: address,
                            city: city,
                            state: state,
                            zip: zip,
                            country: country,
                            jobTitle: jobTitle,
                            notes: notes,
                            funnelID: funnelID,
                            stageID: stageID,
                            assignedTo: assignedTo,
                            latitude: latitude,
                            longitude: longitude,
                            priority: priority
                        )
                    } else {
                        try await viewModel.createLead(
                            name: name,
                            email: email,
                            phone: phone,
                            company: company,
                            source: source,
                            address: address,
                            city: city,
                            state: state,
                            zip: zip,
                            country: country,
                            jobTitle: jobTitle,
                            notes: notes,
                            funnelID: funnelID,
                            stageID: stageID,
                            assignedTo: assignedTo,
                            latitude: latitude,
                            longitude: longitude,
                            type: type,
                            priority: priority
                        )
                    }
                } catch {
                    Toast.error(error)
                    shouldDisplayRequiredIndicators = true
                }
                navigation.dismissModal()
            } label: {
                Text(lead == nil ? "Create" : "Update")
                    .frame(height: 52)
                    .maxReadableWidth()
                    .background(FunnelminkGradient())
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .multilineTextAlignment(.leading)
            .padding()
        }
        .loggedTask {
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
            do {
                try await viewModel.setUp(funnelID: initialFunnelD, stageID: initialStageID, lead: lead)
            } catch {
                Toast.error(error)
            }
        }
    }
}

#Preview {
    EditLeadView()
        .withPreviewDependencies()
}
