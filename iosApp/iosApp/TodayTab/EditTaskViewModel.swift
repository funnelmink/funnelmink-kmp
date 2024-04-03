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
        var task: TaskRecord?
    }
    
    @MainActor
    func createTask(title: String, priority: Int32, body: String, scheduledDate: String?, onSuccess: @escaping () -> Void) async {
        if title.isEmpty {
            Toast.error("Pretend success!")
            return
        }
        // TODO: validation
//        if !Validator.isValidName(title) {
//            state.creationErrorMessage = "`\(title)` is not a valid Task name."
//            return
//        }
        do {
            let body = CreateTaskRequest(
                title: title,
                body: body, 
                priority: Int32(priority),
                scheduledDate: scheduledDate
            )
            _ = try await Networking.api.createTask(body: body)
            onSuccess()
        } catch {
            Toast.error(error)
        }
    }
    
    @MainActor
    func updateTask(id: String, title: String, priority: Int32, isComplete: Bool,  body: String?, scheduledDate: String?, onSuccess: @escaping () -> Void) async {
        if title.isEmpty {
            Toast.error("Task name cannot be empty.")
            return
        }
//        if !Validator.isValidName(title) {
//            state.creationErrorMessage = "`\(title)` is not a valid Task name."
//            return
//        }
        do {
            let body = UpdateTaskRequest(
                title: title,
                body: body, 
                priority: Int32(priority),
                isComplete: isComplete,
                scheduledDate: scheduledDate
            )
            _ = try await Networking.api.updateTask(id: id, body: body)
            onSuccess()
        } catch {
            Toast.error(error)
        }
    }
}
