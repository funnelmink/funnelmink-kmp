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
        var stages: [FunnelStage] = []
        var selectedStage: FunnelStage = FunnelStage(id: "", name: "", order: 0)
        
        var members: [WorkspaceMember] = []
        var assignedMember: WorkspaceMember? // TODO: be able to assign to members. Copy the way we select stages
    }
    
    @MainActor
    func setUp(caseRecord: CaseRecord?) async throws {
        var state = self.state
        // fire both requests at the same time (don't wait for stages to come back before requesting members)
        async let stages = Networking.api.getFunnelStages(type: .case)
        async let members = Networking.api.getWorkspaceMembers()
        state.stages = try await stages
        state.members = try await members
        if let first = state.stages.first {
            state.selectedStage = first
        }
        if let caseRecord = caseRecord {
            state.assignedMember = state.members.first(where: { $0.id == caseRecord.assignedToID })
            state.selectedStage = state.stages.first(where: { $0.id == caseRecord.stageID }) ?? state.selectedStage
        }
        self.state = state
    }
    
    @MainActor
    func createCase(
        name: String,
        description: String?,
        value: String,
        priority: Int32,
        notes: String?,
        accountID: String
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
            assignedTo: state.assignedMember?.id,
            stageID: state.selectedStage.id
        )
        _ = try await Networking.api.createCase(body: body)
    }
    
    @MainActor
    func updateCase(
        id: String,
        name: String,
        description: String?,
        value: String,
        priority: Int32,
        notes: String?
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
            assignedTo: state.assignedMember?.id,
            stageID: state.selectedStage.id
        )
        _ = try await Networking.api.updateCase(id: id, body: body)
    }
}

