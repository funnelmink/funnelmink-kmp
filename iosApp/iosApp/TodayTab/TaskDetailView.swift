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
            HStack {
                Text(task.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                    .strikethrough(task.isComplete)
                Spacer()
                
                TaskCompletionButton(task: task) {
                    Task {
                        do {
                            _ = try await Networking.api.toggleTaskCompletion(id: task.id, isComplete: !task.isComplete)
                            navigation.popSegue()
                        } catch {
                            appState.error = error
                        }
                    }
                }
            }
            .padding(.horizontal)
            ScrollView {
                if let date = task.scheduledDate?.toDate()?.toTaskSectionTitle() {
                    Text(date)
                }
                Divider()
                HStack {
                    Text("Priority:")
                    Label(
                        task.priority.priorityName,
                        systemImage: task.priority.priorityIconName
                    )
                }
                .foregroundStyle(task.priority.priorityColor)
                
                if let body = task.body {
                    Divider()
                    Text(body)
                        .padding(.horizontal)
                }
                
            }
        }
        .navigationBarTitleDisplayMode(.inline)
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
    TaskDetailView(task: ScheduleTask(id: "", title: .loremShort, body: .loremLong, priority: 2, isComplete: false, scheduledDate: "2024-01-20T00:31:00-03:00"))
}
