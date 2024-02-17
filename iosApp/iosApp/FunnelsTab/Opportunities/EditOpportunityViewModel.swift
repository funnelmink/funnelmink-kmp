//
//  EditOpportunityViewModel.swift
//  iosApp
//
//  Created by Jared Warren on 2/16/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation
import Shared

class EditOpportunityViewModel: ViewModel {
    @Published var state = State()
    
    struct State: Hashable {
        var selectedFunnel: Funnel = Funnel(id: "", name: "", type: .opportunity, stages: [], cases: [], leads: [], opportunities: [])
        var selectedStage: FunnelStage = FunnelStage(id: "", name: "", order: 0)
        var funnels: [Funnel] = []
    }
    
    @MainActor
    func setUp(funnelID: String?, stageID: String?, opportunity: Opportunity?) async throws {
        state.funnels = try await Networking.api.getFunnelsForType(funnelType: .opportunity)
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
    func createOpportunity(
        name: String,
        description: String,
        value: String,
        priority: Int32,
        notes: String?,
        accountID: String?,
        assignedTo: String?
    ) async throws {
        guard let val = Double(value) else {
            throw "Value must be a number"
        }
        let body = CreateOpportunityRequest(
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
        _ = try await Networking.api.createOpportunity(body: body)
    }
    
    @MainActor
    func updateOpportunity(
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
        let body = UpdateOpportunityRequest(
            name: name,
            description: description,
            value: val,
            priority: priority,
            notes: notes,
            assignedTo: assignedTo,
            stageID: state.selectedStage.id,
            funnelID: state.selectedFunnel.id
        )
        _ = try await Networking
            .api
            .updateOpportunity(
                id: id,
                body: body
            )
    }
}
