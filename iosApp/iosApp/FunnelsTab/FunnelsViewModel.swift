//
//  FunnelsViewModel.swift
//  iosApp
//
//  Created by Jared Warren on 1/26/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation
import Shared

class FunnelsViewModel: ViewModel, KanbanViewModel {
    @Published var columns: [KanbanColumn] = []
    @Published var state = State()
    
    struct State: Hashable {
        var funnels: [Funnel] = []
        var isInitialized = false
    }
    
    @MainActor
    func setUp(initialSelection: String) async throws {
        if !state.isInitialized {
            try await fetchFunnels()
        }
    }
    
    func selectFunnel(_ funnel: Funnel) {
        columns.removeAll()
        funnel.stages.forEach { stage in
            let column = KanbanColumn(
                id: stage.id,
                title: stage.name,
                cards: [] // todo
            )
            columns.append(column)
        }
    }
    
    func selectFunnel(_ name: String) {
        guard let funnel = state.funnels.first(where: { $0.name == name }) else { return }
        selectFunnel(funnel)
    }
    
    @MainActor
    private func fetchFunnels() async throws {
        let funnels = try await Networking.api.getFunnels()
        selectFunnel(funnels.first!)
        var state = self.state
        state.funnels = funnels
        state.isInitialized = true
        self.state = state
    }
    
    @MainActor
    func createDefaultFunnels() async throws {
        try await Networking.api.createDefaultFunnels()
        try await fetchFunnels()
    }
}
