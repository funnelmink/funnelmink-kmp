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
        var creationErrorMessage: String?
    }
    
    @MainActor
    func getTasks() async {
        do {
            let tasks = try await Networking.api.getTasks(date: nil, priority: nil, limit: nil, offset: nil)
            state.tasks = Dictionary(grouping: tasks, by: { $0.scheduledDate ?? "" })
        } catch {
            AppState.shared.error = error
        }
    }
    
    
    // TODO: all task parameters - prio, date, body
    @MainActor
    func createTask(title: String, priority: Int, body: String?, scheduledDate: String?, onSuccess: @escaping () -> Void) async {
        state.creationErrorMessage = nil
        if title.isEmpty {
            state.creationErrorMessage = "Task name cannot be empty."
            return
        }
        if !Utilities.validation.isName(input: title) {
            state.creationErrorMessage = "`\(title)` is not a valid Task name."
            return
        }
        do {
            let body = CreateTaskRequest(
                title: title,
                priority: Int32(priority),
                body: body,
                scheduledDate: scheduledDate
            )
            let task = try await Networking.api.createTask(body: body)
            state.tasks[task.scheduledDate ?? ""]?.append(task)
            onSuccess()
        } catch {
            state.creationErrorMessage = "\(error)"
        }
    }
}
