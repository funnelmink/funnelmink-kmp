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
        var selectedFunnel: Funnel = Funnel(id: "", name: "", type: .lead, stages: [], cases: [], leads: [], opportunities: [])
        var selectedStage: FunnelStage = FunnelStage(id: "", name: "", order: 0)
        var funnels: [Funnel] = []
    }
    
    @MainActor
    func setUp(funnelID: String?, stageID: String?, lead: Lead?) async throws {
        state.funnels = try await Networking.api.getFunnelsForType(funnelType: .lead)
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
    func createLead(
        name: String,
        email: String?,
        phone: String?,
        company: String?,
        source: String?,
        address: String?,
        city: String?,
        state: String?,
        zip: String?,
        country: String?,
        jobTitle: String?,
        notes: String?,
        assignedTo: String?,
        latitude: Double?,
        longitude: Double?,
        priority: Int32
    ) async throws {
        let body = CreateLeadRequest(
            name: name,
            email: email,
            phone: phone,
            latitude: latitude?.kotlinValue,
            longitude: longitude?.kotlinValue,
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
            accountID: nil,
            assignedTo: assignedTo?.nilIfEmpty(),
            funnelID: self.state.selectedFunnel.id,
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
        company: String?,
        source: String?,
        address: String?,
        city: String?,
        state: String?,
        zip: String?,
        country: String?,
        jobTitle: String?,
        notes: String?,
        assignedTo: String?,
        latitude: Double?,
        longitude: Double?,
        priority: Int32
    ) async throws {
        let body = UpdateLeadRequest(
            name: name,
            email: email,
            phone: phone,
            latitude: latitude?.kotlinValue,
            longitude: longitude?.kotlinValue,
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
            accountID: nil,
            assignedTo: assignedTo?.nilIfEmpty(),
            funnelID: self.state.selectedFunnel.id,
            stageID: self.state.selectedStage.id
        )
        // don't need to store the result
        _ = try await Networking.api.updateLead(id: leadID, body: body)
    }
}
