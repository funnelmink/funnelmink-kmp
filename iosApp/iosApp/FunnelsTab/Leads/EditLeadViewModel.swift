//
//  EditLeadViewModel.swift
//  iosApp
//
//  Created by Jared Warren on 2/9/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation
import Shared

class EditLeadViewModel: ViewModel {
    @Published var state = State()
    
    struct State: Hashable {
        var stages: [FunnelStage] = []
        var selectedStage: FunnelStage = FunnelStage(id: "", name: "", order: 0)
        
        var members: [WorkspaceMember] = []
        var assignedMember: WorkspaceMember? // TODO: be able to assign to members. Copy the way we select stages
    }
    
    @MainActor
    func setUp(lead: Lead?) async throws {
        var state = self.state
        // fire both requests at the same time (don't wait for stages to come back before requesting members)
        async let stages = Networking.api.getFunnelStages(type: .lead)
        async let members = Networking.api.getWorkspaceMembers()
        state.stages = try await stages
        state.members = try await members
        if let first = state.stages.first {
            state.selectedStage = first
        }
        if let lead {
            state.assignedMember = state.members.first(where: { $0.id == lead.assignedToID })
            state.selectedStage = state.stages.first(where: { $0.id == lead.stageID }) ?? state.selectedStage
        }
        self.state = state
    }
    
    @MainActor
    func createLead(
        name: String,
        email: String?,
        phone: String?,
        latitude: String?,
        longitude: String?,
        address: String?,
        city: String?,
        state: String?,
        country: String?,
        zip: String?,
        notes: String?,
        company: String?,
        jobTitle: String?,
        priority: Int32,
        source: String?,
        assignedTo: String?
    ) async throws {
        let body = CreateLeadRequest(
            name: name,
            email: email,
            phone: phone,
            latitude: nil, // TODO: gps location
            longitude: nil,
            address: address,
            city: city,
            state: state,
            country: country,
            zip: zip,
            notes: notes,
            company: company,
            jobTitle: jobTitle,
            priority: priority.kotlinValue,
            source: source,
            assignedTo: assignedTo,
            stageID: self.state.selectedStage.id
        )
        // don't need to store the result
        _ = try await Networking.api.createLead(body: body)
    }
    
    @MainActor
    func updateLead(
        leadID: String,
        name: String,
        email: String?,
        phone: String?,
        latitude: String?,
        longitude: String?,
        address: String?,
        city: String?,
        state: String?,
        country: String?,
        zip: String?,
        notes: String?,
        company: String?,
        jobTitle: String?,
        priority: Int32?,
        source: String?,
        assignedTo: String?
    ) async throws {
        let body = UpdateLeadRequest(
            name: name,
            email: email,
            phone: phone,
            latitude: nil, // TODO: gps location
            longitude: nil,
            address: address,
            city: city,
            state: state,
            country: country,
            zip: zip,
            notes: notes,
            company: company,
            jobTitle: jobTitle,
            priority: priority?.kotlinValue,
            source: source,
            assignedTo: assignedTo,
            stageID: self.state.selectedStage.id
        )
        // don't need to store the result
        _ = try await Networking.api.updateLead(id: leadID, body: body)
    }
}
