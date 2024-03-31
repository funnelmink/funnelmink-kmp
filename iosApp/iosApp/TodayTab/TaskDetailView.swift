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
    @State var task: TaskRecord
    var body: some View {
        VStack {
            HStack {
                Text(task.title)
                    .font(.title2.bold())
                    .padding(.top)
                    .strikethrough(task.isComplete)
                Spacer()
                
                TaskCompletionButton(task: task) {
                    Task {
                        do {
                            _ = try await Networking.api.toggleTaskCompletion(id: task.id, isComplete: !task.isComplete)
                            navigation.popSegue()
                        } catch {
                            Toast.error(error)
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
                
                if !task.body.isEmpty {
                    Divider()
                    Text(task.body)
                        .padding(.horizontal)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            WarningAlertButton(warningMessage: "Delete task?") {
                Task {
                    do {
                        try await Networking.api.deleteTask(id: task.id)
                        navigation.popSegue()
                    } catch {
                        Toast.warn(error)
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
                    navigation.modalSheet(.editTask(task)) {
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
        .logged(info: task.id)
    }
}
