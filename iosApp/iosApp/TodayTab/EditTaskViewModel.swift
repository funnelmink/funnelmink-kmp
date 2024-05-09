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
    func createTask(title: String, priority: Int32, body: String, date: String?, time: String?, duration: Int32?, visibility: RecordVisibility, assignedTo: String, onSuccess: @escaping () -> Void) async {
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
            var kDuration: KotlinInt?
            if let duration { kDuration = KotlinInt(int: duration) }
            let body = CreateTaskRequest(
                title: title,
                body: body,
                priority: priority,
                date: date,
                time: time,
                duration: kDuration,
                visibility: visibility,
                assignedTo: assignedTo
            )
            _ = try await Networking.api.createTask(body: body)
            onSuccess()
        } catch {
            Toast.error(error)
        }
    }
    
    @MainActor
    func updateTask(id: String, title: String, priority: Int32, duration: Int32?, isComplete: Bool, body: String, scheduledDate: String?, onSuccess: @escaping () -> Void) async {
        if title.isEmpty {
            Toast.error("Task name cannot be empty.")
            return
        }
//        if !Validator.isValidName(title) {
//            state.creationErrorMessage = "`\(title)` is not a valid Task name."
//            return
//        }
        do {
            var kDuration: KotlinInt?
            if let duration { kDuration = KotlinInt(int: duration) }
            let body = UpdateTaskRequest(title: title, body: body, priority: priority, isComplete: isComplete, date: scheduledDate, time: nil, duration: kDuration, visibility: .onlyMe, assignedTo: AppState.shared.user!.id)
            _ = try await Networking.api.updateTask(id: id, body: body)
            onSuccess()
        } catch {
            Toast.error(error)
        }
    }
}
