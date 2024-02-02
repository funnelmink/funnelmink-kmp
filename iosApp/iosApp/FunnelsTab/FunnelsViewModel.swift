//
//  FunnelsViewModel.swift
//  iosApp
//
//  Created by Jared Warren on 1/26/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation

class FunnelsViewModel: ViewModel, KanbanViewModel {
    @Published var columns: [KanbanColumn] = []
    @Published var state = State()
    
    struct State: Hashable {
        
    }
    
    func fetch() async throws {
//        let funnels = try await FunnelMinkAPI.shared.funnels()
//        columns = funnels.map { KanbanColumn(funnel: $0) }
    }
}
