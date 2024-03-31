//
//  CaseDetailView.swift
//  iosApp
//
//  Created by Jared Warren on 2/12/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Shared
import SwiftUI

struct CaseDetailView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigation: Navigation
    @State var caseRecord: CaseRecord
    var closedPrompt: String? {
        if let closedDate = caseRecord.closedDate?.toDate()?.toTaskSectionTitle() {
            return "This Case was closed on \(closedDate)"
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
                LabeledRow(name: "Value", value: caseRecord.value.currencyFormat)
                Section("CASE MANAGEMENT") {
                    if let assignedTo = caseRecord.assignedToName {
                        LabeledRow(name: "Assigned To", value: assignedTo)
                    }
                    LabeledRow(
                        name: "Priority",
                        value: caseRecord.priority.priorityName,
                        imageName: caseRecord.priority.priorityIconName,
                        valueColor: caseRecord.priority.priorityColor
                    )
                }
                
                if !caseRecord.notes.isEmpty {
                    Section("NOTES") {
                        Text(caseRecord.notes)
                    }
                }
            }
            HStack {
                WarningAlertButton(warningMessage: "Are you sure you want to delete this case?") {
                    Task {
                        do {
                            try await Networking.api.deleteCase(id: caseRecord.id)
                            navigation.popSegue()
                        } catch {
                            Toast.warn(error)
                        }
                    }
                } label: {
                    Text("Delete Case")
                        .foregroundStyle(.red)
                }
                Spacer()
                Button("Close Case") {
                    navigation.modalSheet(.closeRecord(type: .case, id: caseRecord.id), onDismiss: refreshCase)
                }
            }
            .padding()
        }
        .navigationTitle(caseRecord.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    navigation.modalSheet(.editCase(caseRecord: caseRecord), onDismiss: refreshCase)
                } label: {
                    Text("Edit")
                }
            }
        }
        .logged(info: caseRecord.id)
    }
    
    private func refreshCase() {
        Task { @MainActor in
            caseRecord = try await Networking.api.getCase(id: caseRecord.id)
        }
    }
}

#Preview {
    CaseDetailView(
        caseRecord: TestData.caseRecord
    )
    .withPreviewDependencies()
}
