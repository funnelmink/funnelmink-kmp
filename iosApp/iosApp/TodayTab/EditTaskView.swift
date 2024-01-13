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
    @State var createTaskName = ""
    @State var taskBody = ""
    @State var priority: Int32 = 0
    @State var date: Date?
    var task: ScheduleTask?
    
    var body: some View {
        VStack {
            Text(task == nil ? "Create Task" : "Edit Task")
                .font(.title)
                .fontWeight(.bold)
            List {
                Section("TITLE") {
                    TextField(
                        "",
                        text: $createTaskName,
                        prompt: Text("Ex. Place a call")
                            .foregroundColor(.gray)
                    )
                    .frame(minHeight: 44)
                }
                
                Section("DESCRIPTION") {
                    TextField("", text: $taskBody, prompt: Text("(Optional)").foregroundColor(.gray))
                        .frame(minHeight: 44)
                }
                
                
                Section("OPTIONS") {
                    Picker(selection: $priority, label: Text("Priority")) {
                        Label("Low", systemImage: "gauge.with.dots.needle.0percent")
                            .tag(Int32(0))
                        Label("Medium", systemImage: "gauge.with.dots.needle.33percent")
                            .tag(Int32(1))
                        Label("High", systemImage: "gauge.with.dots.needle.67percent")
                            .tag(Int32(2))
                        Label("Ultra", systemImage: "gauge.with.dots.needle.100percent")
                            .tag(Int32(3))
                    }
                    .pickerStyle(.menu)
                    .tint(
                        priority == 0 ? .gray :
                            priority == 1 ? .blue :
                            priority == 2 ? .purple : .red
                    )
                    .frame(height: 52)
                    if let date {
                        HStack {
                            DatePicker(
                                "Date",
                                selection: Binding(
                                    get: { date },
                                    set: { self.date = $0 }
                                ),
                                displayedComponents: [.date, .hourAndMinute]
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
                                date = Date().addingTimeInterval(60 * 60 * 24)
                            } label: {
                                Text("Add date")
                                    .frame(height: 52)
                            }
                        }
                    }
                }
                
                
            }
            AsyncButton {
                await viewModel.createTask(title: createTaskName, priority: 1, body: nil, scheduledDate: nil) {
                    navigation.dismissModal()
                }
            } label: {
                Text(task == nil ? "Create" : "Update")
                    .frame(height: 52)
                    .maxReadableWidth()
                    .background(LoginBackgroundGradient())
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .multilineTextAlignment(.leading)
            .padding()
        }
        .multilineTextAlignment(.center)
        .onAppear {
            if let task = task {
                createTaskName = task.title
                priority = task.priority
                date = task.scheduledDate?.toDate()
            }
        }
    }
}

#Preview {
    EditTaskView(viewModel: .init())
}
