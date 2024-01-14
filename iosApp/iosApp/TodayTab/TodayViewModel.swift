//
//  TodayViewModel.swift
//  iosApp
//
//  Created by Jared Warren on 1/11/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation
import Shared

class TodayViewModel: ViewModel {
    @Published var state = State()
    
    struct State: Hashable {
        var tasks: [String: [ScheduleTask]] = [:]
    }
    
    @MainActor
    func getTasks() async {
        do {
            let tasks = try await Networking.api.getTasks(date: nil, priority: nil, limit: nil, offset: nil)
            state.tasks = Dictionary(grouping: tasks, by: { $0.scheduledDate?.toDate()?.toNumberRelativeAndWeekday() ?? "" })
        } catch {
            AppState.shared.error = error
        }
    }
}
