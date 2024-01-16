//
//  TaskDetailView.swift
//  iosApp
//
//  Created by Jared Warren on 1/15/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Shared
import SwiftUI

struct TaskDetailView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigation: Navigation
    let task: ScheduleTask
    var body: some View {
        VStack {
            
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        navigation.presentSheet(.editTask(task))
                    } label: {
                        Text("Edit task")
                    }
                    Button("Delete task", role: .destructive) {
                        Task {
                            do {
                                try await Networking.api.deleteTask(id: task.id)
                                navigation.popSegue()
                            } catch {
                                appState.error = error
                            }
                        }
                    }
                } label: {
                    Label("Options", systemImage: "ellipsis.circle")
                }
            }
        }
    }
}

#Preview {
    TaskDetailView(task: ScheduleTask(id: "", title: "Test", body: "Test Body", priority: 0, isComplete: false, scheduledDate: nil))
}
