//
//  EditCaseView.swift
//  iosApp
//
//  Created by Jared Warren on 2/9/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Shared
import SwiftUI

struct EditCaseView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigation: Navigation
    @StateObject var viewModel = EditCaseViewModel()
    
    @State var members: [WorkspaceMember] = []
    @State private var assignedTo = ""
    @State private var description = ""
    @State private var name = ""
    @State private var notes = ""
    @State private var priority: Int32 = 0
    @State private var stageID = ""
    @State private var value = ""
    
    @State private var shouldDisplayRequiredIndicators = false
    
    var caseRecord: CaseRecord?
    var accountID: String?
    
    var body: some View {
        VStack {
            List {
                Text(caseRecord == nil ? "New Case" : "Edit Case")
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
                
                Section("CASE MANAGEMENT") {
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
                    
                    Picker(selection: $assignedTo, label: Text("Assigned Member")) {
                        ForEach(members, id: \.self) { member in
                            Text(member.username).tag(member.id)
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
                    if let caseRecord {
                        try await viewModel.updateCase(
                            id: caseRecord.id,
                            name: name,
                            description: description,
                            value: value,
                            priority: priority,
                            notes: notes,
                            assignedTo: assignedTo
                        )
                    } else if let accountID {
                        try await viewModel.createCase(
                            name: name,
                            description: description,
                            value: value,
                            priority: priority,
                            notes: notes,
                            accountID: accountID,
                            assignedTo: assignedTo
                        )
                    } else {
                        Toast.warn("This case needs to be linked to an Account")
                    }
                    navigation.dismissModal()
                    Toast.success("Case created")
                } catch {
                    Toast.warn(error)
                }
            } label: {
                Text(caseRecord == nil ? "Create" : "Update")
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
            if let caseRecord {
                name = caseRecord.name
                description = caseRecord.description_
                priority = caseRecord.priority
                notes = caseRecord.notes
                value = "\(caseRecord.value)"
                stageID = caseRecord.stageID
            }
            
            do {
                async let workspaceMembers = Networking.api.getWorkspaceMembers()
                members = try await workspaceMembers
            } catch {
                Toast.warn(error)
            }
            
            do {
                try await viewModel.setUp(caseRecord: caseRecord)
            } catch {
                Toast.warn(error)
            }
        }
    }
}

#Preview {
    EditCaseView(accountID: TestData.account.id)
        .withPreviewDependencies()
}
