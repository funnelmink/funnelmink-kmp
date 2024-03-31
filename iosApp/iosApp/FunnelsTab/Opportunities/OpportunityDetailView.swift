//
//  OpportunityDetailView.swift
//  iosApp
//
//  Created by Jared Warren on 2/12/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Shared
import SwiftUI

struct OpportunityDetailView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigation: Navigation
    @State var opportunity: Opportunity
    var closedPrompt: String? {
        if let closedDate = opportunity.closedDate?.toDate()?.toTaskSectionTitle() {
            return "This Opportunity was closed on \(closedDate)"
        }
        return nil
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
                LabeledRow(name: "Value", value: opportunity.value.currencyFormat)
                Section("OPPORTUNITY MANAGEMENT") {
                    if let assignedTo = opportunity.assignedToName {
                        LabeledRow(name: "Assigned To", value: assignedTo)
                    }
                    LabeledRow(
                        name: "Priority",
                        value: opportunity.priority.priorityName,
                        imageName: opportunity.priority.priorityIconName,
                        valueColor: opportunity.priority.priorityColor
                    )
                }
                
                if !opportunity.notes.isEmpty {
                    Section("NOTES") {
                        Text(opportunity.notes)
                    }
                }
            }
            HStack {
                WarningAlertButton(warningMessage: "Are you sure you want to delete this opportunity?") {
                    Task {
                        do {
                            try await Networking.api.deleteOpportunity(id: opportunity.id)
                            navigation.popSegue()
                        } catch {
                            Toast.warn(error)
                        }
                    }
                } label: {
                    Text("Delete Opportunity")
                        .foregroundStyle(.red)
                }
                Spacer()
                Button("Close Opportunity") {
                    navigation.modalSheet(.closeRecord(type: .opportunity, id: opportunity.id), onDismiss: refreshOpportunity)
                }
            }
            .padding()
        }
        .navigationTitle(opportunity.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    navigation.modalSheet(.editOpportunity(opportunity: opportunity), onDismiss: refreshOpportunity)
                } label: {
                    Text("Edit")
                }
            }
        }
        .logged(info: opportunity.id)
    }
    
    private func refreshOpportunity() {
        Task { @MainActor in
            opportunity = try await Networking.api.getOpportunity(id: opportunity.id)
        }
    }
}
