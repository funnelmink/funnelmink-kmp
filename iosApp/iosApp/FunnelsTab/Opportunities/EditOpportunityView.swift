//
//  EditOpportunityView.swift
//  iosApp
//
//  Created by Jared Warren on 2/9/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Shared
import SwiftUI

struct EditOpportunityView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigation: Navigation
    @StateObject var viewModel = EditOpportunityViewModel()
    
    @State private var assignedTo = ""
    @State private var closedDate = ""
    @State private var description = ""
    @State private var name = ""
    @State private var notes = ""
    @State private var priority: Int32 = 0
    @State private var stageID = ""
    @State private var value = ""
    
    @State private var shouldDisplayRequiredIndicators = false
    
    var opportunity: Opportunity?
    var initialFunnelD: String?
    var initialStageID: String?
    var accountID: String?
    
    var body: some View {
        VStack {
            List {
                Text(opportunity == nil ? "New Opportunity" : "Edit Opportunity")
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
                    CustomTextField(text: $description, placeholder: "Description", style: .text)
                        .autocorrectionDisabled()
                        .discreteListRowStyle()
                    
                    CustomTextField(
                        text: $value,
                        placeholder: "Value",
                        style: .decimal
                    )
                    .discreteListRowStyle()
                }
                
                Section("OPPORTUNITY MANAGEMENT") {
                    CustomTextField(text: $assignedTo, placeholder: "Assigned To", style: .text)
                        .autocorrectionDisabled()
                        .discreteListRowStyle()
                    
                    // TODO: assign it to an account. will need to fetch all accounts
                    
                    Picker(selection: $priority, label: Text("Priority")) {
                        ForEach(Int32(0)..<4, id: \.self) { prio in
                            Label(" " + prio.priorityName, systemImage: prio.priorityIconName)
                                .tag(prio)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(priority.priorityColor)
                    
                    Picker(selection: $viewModel.state.selectedFunnel, label: Text("Funnel")) {
                        ForEach(viewModel.state.funnels, id: \.self) { funnel in
                            Text(funnel.name).tag(funnel.id)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Picker(selection: $viewModel.state.selectedStage, label: Text("Stage")) {
                        ForEach(viewModel.selectedFunnel.stages, id: \.self) { stage in
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
                    if let opportunity {
                        try await viewModel.updateOpportunity(
                            id: opportunity.id,
                            name: name,
                            description: description,
                            value: value,
                            priority: priority,
                            notes: notes,
                            assignedTo: assignedTo
                        )
                    } else if let accountID {
                        try await viewModel.createOpportunity(
                            name: name,
                            description: description,
                            value: value,
                            priority: priority,
                            notes: notes,
                            accountID: accountID,
                            assignedTo: assignedTo
                        )
                    } else {
                        Toast.warn("This Opportunity needs to be linked to an Account")
                    }
                    navigation.dismissModal()
                    Toast.success("Opportunity created")
                } catch {
                    Toast.warn(error)
                }
            } label: {
                Text(opportunity == nil ? "Create" : "Update")
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
            if let opportunity {
                name = opportunity.name
                description = opportunity.description_ ?? ""
                assignedTo = opportunity.assignedTo ?? ""
                priority = opportunity.priority
                notes = opportunity.notes ?? ""
                value = "\(opportunity.value)"
                closedDate = opportunity.closedDate ?? ""
                stageID = opportunity.stageID ?? ""
            }
            do {
                try await viewModel.setUp(funnelID: initialFunnelD, stageID: initialStageID, opportunity: opportunity)
            } catch {
                Toast.warn(error)
            }
        }
    }
}

#Preview {
    EditOpportunityView(accountID: TestData.account.id)
        .withPreviewDependencies()
}
