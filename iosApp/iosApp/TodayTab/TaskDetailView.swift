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
    @State var task: ScheduleTask
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
            WarningAlertButton(warningMessage: "Delete task?") {
                Task {
                    do {
                        try await Networking.api.deleteTask(id: task.id)
                        navigation.popSegue()
                    } catch {
                        appState.error = error
                    }
                }
            } label: {
                Text("Delete task")
                    .foregroundStyle(.red)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    navigation.presentSheet(.editTask(task)) {
                        Task {
                            if let task = try? await Networking.api.getTask(id: task.id) {
                                self.task = task
                            }
                        }
                    }
                } label: {
                    Text("Edit")
                }
            }
        }
    }
}

#Preview {
    TaskDetailView(
        task: ScheduleTask(
            id: "",
            title: .loremShort,
            body: .loremLong,
            priority: 2,
            isComplete: false,
            scheduledDate: .loremDate
        )
    )
}
