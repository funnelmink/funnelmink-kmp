//
//  TodayViewModel.swift
//  iosApp
//
//  Created by Jared Warren on 1/11/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Combine
import Foundation
import Shared

class TodayViewModel: ViewModel {
    @Published var state = State()
    @Published var searchText = ""
    private var subscriptions = Set<AnyCancellable>()
    
    struct State: Hashable {
        var tasksByDate: [Date: [ScheduleTask]] = [:]
        var tasksByPriority: [Int32: [ScheduleTask]] = [:]
        var completedTasks: [ScheduleTask] = []
    }
    
    init() {
        // clear everything when the user changes workspaces
        AppState
            .shared
            .$workspace
            .sink { _ in
                self.state = State()
            }
            .store(in: &subscriptions)
    }
    
    var tasksByDateSearchResults: [Date: [ScheduleTask]] {
        if searchText.isEmpty { return state.tasksByDate }
        var results: [Date: [ScheduleTask]] = [:]
        for (key, value) in state.tasksByDate {
            results[key] = value.filter { $0.description.lowercased().contains(searchText.lowercased()) }
        }
        return results
    }
    var tasksByPrioritySearchResults: [Int32: [ScheduleTask]] {
        if searchText.isEmpty { return state.tasksByPriority }
        var results: [Int32: [ScheduleTask]] = [:]
        for (key, value) in state.tasksByPriority {
            results[key] = value.filter { $0.description.lowercased().contains(searchText.lowercased()) }
        }
        return results
    }
    var completedTasksSearchResults: [ScheduleTask] {
        if searchText.isEmpty { return state.completedTasks }
        return state.completedTasks.filter { $0.description.lowercased().contains(searchText.lowercased()) }
    }
    
    @MainActor
    func getTasks() async {
        do {
            let tasks = try await Networking.api.getTasks()
            
            state.tasksByDate = Dictionary(
                grouping: tasks,
                by: { $0.scheduledDate?.toSortableDate() ?? Date.distantPast }
            )
            state.tasksByPriority = Dictionary(grouping: tasks, by: { $0.priority })
        } catch {
            AppState.shared.error = error
        }
    }
    
    @MainActor
    func getCompletedTasks() async {
        do {
            state.completedTasks = try await Networking
                .api
                .getCompletedTasks()
                .sorted { ($0.updatedAt.toDate() ?? Date()) < ($1.updatedAt.toDate() ?? Date()) }
        } catch {
            AppState.shared.error = error
        }
    }
    
    @MainActor
    func toggleIsComplete(for task: ScheduleTask) async {
        do {
            _ = try await Networking.api.toggleTaskCompletion(id: task.id, isComplete: !task.isComplete)
        } catch {
            AppState.shared.error = error
        }
    }
}
