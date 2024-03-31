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
    @State private var city = ""
    @State private var closedResult: LeadClosedResult?
    @State private var company = ""
    @State private var country = ""
    @State private var createdAt = ""
    @State private var email = ""
    @State private var jobTitle = ""
    @State private var latitude = ""
    @State private var longitude = ""
    @State private var name = ""
    @State private var notes = ""
    @State private var phone = ""
    @State private var priority: Int32 = 0
    @State private var source = ""
    @State private var state = ""
    @State private var updatedAt = ""
    @State private var zip = ""
    
    @State private var shouldDisplayRequiredIndicators = false
    
    var lead: Lead?
    
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
                    CustomTextField(text: $jobTitle, placeholder: "Job Title", style: .text)
                        .autocorrectionDisabled()
                        .discreteListRowStyle()
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
                
                Section("GEO LOCATION") {
                    CustomTextField(text: $latitude, placeholder: "Latitude", style: .decimal)
                        .autocorrectionDisabled()
                        .discreteListRowStyle()
                    CustomTextField(text: $longitude, placeholder: "Longitude", style: .decimal)
                        .autocorrectionDisabled()
                        .discreteListRowStyle()
                    Button {
                        // TODO: implement a LocationCoordinator
                        Toast.info("TODO")
                    } label: {
                        HStack {
                            Spacer()
                            Label("Use my current location", systemImage: "location.fill")
                        }
                    }
                    .discreteListRowStyle(backgroundColor: .clear)
                }
                
                Section("LEAD MANAGEMENT") {
                    Picker(selection: $priority, label: Text("Priority")) {
                        ForEach(Int32(0)..<4, id: \.self) { prio in
                            Label(" " + prio.priorityName, systemImage: prio.priorityIconName)
                                .tag(prio)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(priority.priorityColor)
                    
                    Picker(selection: $viewModel.state.selectedStage, label: Text("Stage")) {
                        ForEach(viewModel.state.stages, id: \.self) { stage in
                            Text(stage.name).tag(stage.id)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    
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
                            latitude: latitude,
                            longitude: longitude,
                            address: address,
                            city: city,
                            state: state,
                            country: country,
                            zip: zip,
                            notes: notes,
                            company: company,
                            jobTitle: jobTitle,
                            priority: priority,
                            source: source
                        )
                    } else {
                        try await viewModel.createLead(
                            name: name,
                            email: email,
                            phone: phone,
                            latitude: latitude,
                            longitude: longitude,
                            address: address,
                            city: city,
                            state: state,
                            country: country,
                            zip: zip,
                            notes: notes,
                            company: company,
                            jobTitle: jobTitle,
                            priority: priority,
                            source: source
                        )
                    }
                    navigation.dismissModal()
                } catch {
                    Toast.error(error)
                    shouldDisplayRequiredIndicators = true
                }
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
                self.address = lead.address
                self.city = lead.city
                self.closedResult = lead.closedResult
                self.company = lead.company
                self.country = lead.country
                self.createdAt = lead.createdAt
                self.email = lead.email
                self.jobTitle = lead.jobTitle
                self.name = lead.name
                self.notes = lead.notes
                self.phone = lead.phone
                self.priority = lead.priority
                self.source = lead.source
                self.state = lead.state
                self.updatedAt = lead.updatedAt
                self.zip = lead.zip
                
                if let lat = lead.latitude, let lon = lead.longitude {
                    self.latitude = "\(lat)"
                    self.longitude = "\(lon)"
                }
            }
            do {
                try await viewModel.setUp(lead: lead)
            } catch {
                Toast.warn(error)
            }
        }
    }
}

#Preview {
    EditLeadView()
        .withPreviewDependencies()
}
