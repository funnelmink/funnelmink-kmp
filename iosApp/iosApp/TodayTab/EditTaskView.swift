//
//  EditTaskView.swift
//  iosApp
//
//  Created by Jared Warren on 1/11/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Shared
import SwiftUI

struct EditTaskView: View {
    @EnvironmentObject var navigation: Navigation
    @StateObject var viewModel = EditTaskViewModel()
    @State var taskName = ""
    @State var taskBody = ""
    @State var priority: Int32 = 0
    @State var date: Date?
    var task: TaskRecord?
    
    var body: some View {
        VStack {
            Text(task == nil ? "New Task" : "Edit Task")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.top)
            List {
                Section("TITLE") {
                    TextField(
                        "",
                        text: $taskName,
                        prompt: Text("Ex. Place a call")
                            .foregroundColor(.gray)
                    )
                    .frame(minHeight: 44)
                }
                
                Section("DESCRIPTION") {
                    TextEditor(text: $taskBody)
                        .multilineTextAlignment(.leading)
                        .maxReadableWidth()
                }
                
                
                Section("OPTIONS") {
                    Picker(selection: $priority, label: Text("Priority")) {
                        ForEach(Int32(0)..<4, id: \.self) { prio in
                            Label(" " + prio.priorityName, systemImage: prio.priorityIconName)
                                .tag(prio)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(priority.priorityColor)
                    .frame(height: 52)
                    if let date {
                        HStack {
                            DatePicker(
                                "Date",
                                selection: Binding(
                                    get: { date },
                                    set: { self.date = $0 }
                                ),
                                displayedComponents: [.date]
                            )
                            
                            Button {
                                self.date = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        .frame(height: 52)
                    } else {
                        HStack {
                            Text("Date")
                            Spacer()
                            Button {
                                date = .noon
                            } label: {
                                Text("Add date")
                                    .frame(height: 52)
                            }
                        }
                    }
                }
                
                
            }
            AsyncButton {
                if let task = task {
                    await viewModel.updateTask(
                        id: task.id,
                        title: taskName,
                        priority: priority,
                        isComplete: task.isComplete,
                        body: taskBody,
                        scheduledDate: date?.iso8601()
                    ) {
                        navigation.dismissModal()
                    }
                } else {
                    await viewModel.createTask(
                        title: taskName,
                        priority: priority,
                        body: taskBody,
                        scheduledDate: date?.iso8601()
                    ) {
                        navigation.dismissModal()
                    }
                }
            } label: {
                Text(task == nil ? "Create" : "Update")
                    .frame(height: 52)
                    .maxReadableWidth()
                    .background(FunnelminkGradient())
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .multilineTextAlignment(.leading)
            .padding()
        }
        .multilineTextAlignment(.center)
        .loggedOnAppear {
            if let task = task {
                taskName = task.title
                priority = task.priority
                date = task.scheduledDate?.toDate()
                taskBody = task.body ?? ""
            }
        }
    }
}

#Preview {
    EditTaskView(viewModel: .init())
}
