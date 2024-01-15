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
    
    @Published var searchText = ""
    var tasksByDateSearchResults: [String: [ScheduleTask]] {
        if searchText.isEmpty { return state.tasksByDate }
        var results: [String: [ScheduleTask]] = [:]
        for (key, value) in state.tasksByDate {
            results[key] = value.filter { $0.description.contains(searchText) }
        }
        return results
    }
    var tasksByPrioritySearchResults: [Int32: [ScheduleTask]] {
        if searchText.isEmpty { return state.tasksByPriority }
        var results: [Int32: [ScheduleTask]] = [:]
        for (key, value) in state.tasksByPriority {
            results[key] = value.filter { $0.description.contains(searchText) }
        }
        return results
    }
    
    struct State: Hashable {
        var tasksByDate: [String: [ScheduleTask]] = [:]
        var tasksByPriority: [Int32: [ScheduleTask]] = [:]
        var displayCompletedTasks = false
    }
    
    func toggleDisplayCompletedTasks() {
        state.displayCompletedTasks.toggle()
    }
    
    @MainActor
    func getTasks() async {
        do {
            let tasks = try await Networking.api.getTasks(date: nil, priority: nil, limit: nil, offset: nil)
            state.tasksByDate = Dictionary(grouping: tasks, by: { $0.scheduledDate?.toDate()?.toNumberRelativeAndWeekday() ?? "" })
            state.tasksByPriority = Dictionary(grouping: tasks, by: { $0.priority })
        } catch {
            AppState.shared.error = error
        }
    }
    
    @MainActor
    func toggleIsComplete(for task: ScheduleTask) async {
        do {
            let updated = try await Networking.api.toggleTaskCompletion(id: task.id, isComplete: !task.isComplete)
            updateTask(updated)
        } catch {
            AppState.shared.error = error
        }
    }
    
    private func updateTask(_ task: ScheduleTask) {
        for section in state.tasksByDate.keys {
            if let index = state.tasksByDate[section]?.firstIndex(where: { $0.id == task.id }) {
                state.tasksByDate[section]?[index] = task
            }
        }
        for section in state.tasksByPriority.keys {
            if let index = state.tasksByPriority[section]?.firstIndex(where: { $0.id == task.id }) {
                state.tasksByPriority[section]?[index] = task
            }
        }
    }
}
