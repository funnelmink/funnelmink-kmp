//
//  EditCaseViewModel.swift
//  iosApp
//
//  Created by Jared Warren on 2/17/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation
import Shared

class EditCaseViewModel: ViewModel {
    @Published var state = State()
    
    struct State: Hashable {
        var selectedStage: FunnelStage = FunnelStage(id: "", name: "", order: 0)
    }
    
    @MainActor
    func setUp(funnelID: String?, stageID: String?, caseRecord: CaseRecord?) async throws {
        state.funnels = try await Networking.api.getFunnelsForType(funnelType: .case)
        guard !state.funnels.isEmpty else {
            throw "No funnels found"
        }
        if let funnelID,
           let funnel = state.funnels.first(where: { $0.id == funnelID }),
           let stageID,
           let stage = funnel.stages.first(where: { $0.id == stageID }) {
            state.selectedFunnel = funnel
            state.selectedStage = stage
        } else if let funnel = state.funnels.first,
                  let stage = funnel.stages.first {
            state.selectedFunnel = funnel
            state.selectedStage = stage
        } else {
            throw "No valid funnel found"
        }
    }
    
    @MainActor
    func createCase(
        name: String,
        description: String,
        value: String,
        priority: Int32,
        notes: String?,
        accountID: String,
        assignedTo: String?
    ) async throws {
        guard let val = Double(value) else {
            throw "Value must be a number"
        }
        let body = CreateCaseRequest(
            name: name,
            description: description,
            value: val,
            priority: priority,
            notes: notes,
            accountID: accountID,
            assignedToID: assignedTo?.nilIfEmpty(),
            funnelID: state.selectedFunnel.id,
            stageID: state.selectedStage.id
        )
        _ = try await Networking.api.createCase(body: body)
    }
    
    @MainActor
    func updateCase(
        id: String,
        name: String,
        description: String,
        value: String,
        priority: Int32,
        notes: String?,
        assignedTo: String?
    ) async throws {
        guard let val = Double(value) else {
            throw "Value must be a number"
        }
        let body = UpdateCaseRequest(
            name: name,
            description: description,
            value: val,
            priority: priority,
            notes: notes,
            assignedTo: assignedTo?.nilIfEmpty(),
            stageID: state.selectedStage.id,
            funnelID: state.selectedFunnel.id
        )
        _ = try await Networking.api.updateCase(id: id, body: body)
    }
}

