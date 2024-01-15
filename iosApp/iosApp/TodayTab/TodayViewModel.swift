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
    
    @MainActor
    func toggleIsComplete(for task: ScheduleTask, in section: String) async {
        do {
            let updated = try await Networking.api.toggleTaskCompletion(id: task.id, isComplete: !task.isComplete)
            if let index = state.tasks[section]?.firstIndex(where: { $0.id == task.id }) {
                state.tasks[section]?[index] = updated
            }
        } catch {
            AppState.shared.error = error
        }
    }
}
