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
    func fetch() async throws {
        let funnels = try await Networking.api.getFunnels()
        columns = funnels.map { funnel in
            KanbanColumn(
                id: funnel.id,
                title: funnel.name,
                cards: [] // TODO: bruh
            )
        }
        var state = self.state
        state.funnels = funnels
        state.isInitialized = true
        self.state = state
    }
    
    @MainActor
    func createDefaultFunnels() async throws {
        try await Networking.api.createDefaultFunnels()
        try await fetch()
    }
}
