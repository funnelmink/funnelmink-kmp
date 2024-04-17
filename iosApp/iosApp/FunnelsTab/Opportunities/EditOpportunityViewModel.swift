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
        var stages: [FunnelStage] = []
        var selectedStage: FunnelStage = FunnelStage(id: "", name: "", order: 0)
        
        var members: [WorkspaceMember] = []
        var assignedMember: WorkspaceMember? // TODO: be able to assign to members. Copy the way we select stages
    }
    
    @MainActor
    func setUp(opportunity: Opportunity?) async throws {
        var state = self.state
        // fire both requests at the same time (don't wait for stages to come back before requesting members)
        async let stages = Networking.api.getFunnelStages(type: .opportunity)
        async let members = Networking.api.getWorkspaceMembers()
        state.stages = try await stages
        state.members = try await members
        if let first = state.stages.first {
            state.selectedStage = first
        }
        if let opportunity {
            state.assignedMember = state.members.first(where: { $0.id == opportunity.assignedToID })
            state.selectedStage = state.stages.first(where: { $0.id == opportunity.stageID }) ?? state.selectedStage
        }
        self.state = state
    }
    
    @MainActor
    func createOpportunity(
        name: String,
        description: String?,
        value: String,
        priority: Int32,
        notes: String?,
        accountID: String,
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
            assignedTo: assignedTo,
            stageID: state.selectedStage.id
        )
        _ = try await Networking.api.createOpportunity(body: body)
    }
    
    @MainActor
    func updateOpportunity(
        id: String,
        name: String,
        description: String?,
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
            stageID: state.selectedStage.id
        )
        _ = try await Networking
            .api
            .updateOpportunity(
                id: id,
                body: body
            )
    }
}
