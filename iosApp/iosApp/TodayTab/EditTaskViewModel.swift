//
//  EditTaskViewModel.swift
//  iosApp
//
//  Created by Jared Warren on 1/11/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation
import Shared

class EditTaskViewModel: ViewModel {
    @Published var state = State()
    
    struct State: Hashable {
        var task: ScheduleTask?
        var creationErrorMessage: String?
    }
    
    @MainActor
    func createTask(title: String, priority: Int32, body: String?, scheduledDate: String?, onSuccess: @escaping () -> Void) async {
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
            _ = try await Networking.api.createTask(body: body)
            onSuccess()
        } catch {
            state.creationErrorMessage = "\(error)"
        }
    }
    
    @MainActor
    func updateTask(id: String, title: String, priority: Int32, isComplete: Bool,  body: String?, scheduledDate: String?, onSuccess: @escaping () -> Void) async {
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
            let body = UpdateTaskRequest(
                title: title,
                priority: Int32(priority),
                body: body,
                isComplete: KotlinBoolean(value: isComplete),
                scheduledDate: scheduledDate
            )
            _ = try await Networking.api.updateTask(id: id, body: body)
            onSuccess()
        } catch {
            state.creationErrorMessage = "\(error)"
        }
    }
}
