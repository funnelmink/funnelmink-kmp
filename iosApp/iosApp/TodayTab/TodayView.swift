//
//  HomeView.swift
//  iosApp
//
//  Created by Jared Warren on 10/19/23.
//  Copyright © 2023 FunnelMink. All rights reserved.
//

import Shared
import SwiftUI

struct TodayView: View {
    @EnvironmentObject var navigation: Navigation
    @StateObject var viewModel = TodayViewModel()
    
    @AppStorage(.storage.todayPickerSelection) var selection: Selection = .date
    
    @ViewBuilder
    var body: some View {
        List {
            switch selection {
            case .date: tasksByDate
            case .priority: tasksByPriority
            case .completed: completed
            }
        }
        .searchable(text: $viewModel.searchText)
        .tint(.primary)
        .scrollIndicators(.never)
        .navigationTitle(selection == .completed ? "Completed" : "Tasks")
        .loggedTask {
            await getTasks()
        }
        .onChange(of: selection) { _ in
            Task { await getTasks() }
        }
        .toolbar {
            ToolbarItem {
                Picker("Sort Order", selection: $selection) {
                    Text("By Date").tag(Selection.date)
                    Text("By Priority").tag(Selection.priority)
                    Text("Completed").tag(Selection.completed)
                }
            }
        }
    }
    
    var tasksByDate: some View {
        ForEach(viewModel.tasksByDateSearchResults.keys.sorted(), id: \.self) { section in
            let title = section == .distantPast ? "No Deadline" : section.toTaskSectionTitle()
            Section(header: Text(title)
                .foregroundStyle(title == "No Deadline" ? .gray : title.contains("Today") ? .blue : section < Date() ? .red : .gray)
            ) {
                ForEach(viewModel.tasksByDateSearchResults[section] ?? [], id: \.id, content: cell)
            }
        }
    }
    
    var tasksByPriority: some View {
        ForEach(viewModel.tasksByPrioritySearchResults.keys.sorted(by: >), id: \.self) { section in
            Section(header: Text(section.priorityName)) {
                ForEach(viewModel.tasksByPrioritySearchResults[section] ?? [], id: \.id, content: cell)
            }
        }
    }
    
    var addTaskFAB: some View {
        Button {
            navigation.modalSheet(.createTask) {
                Task {
                    await viewModel.getTasks()
                }
            }
        } label: {
            Image(systemName: "plus")
                .resizable()
                .frame(width: 24, height: 24)
                .padding()
                .foregroundStyle(.white)
                .background(FunnelminkGradient())
                .clipShape(Circle())
        }
        .padding()
    }
    
    @ViewBuilder
    var completed: some View {
        ForEach(viewModel.completedTasksSearchResults, id: \.id, content: cell)
    }
    
    func cell(_ task: TaskRecord) -> some View {
        Button {
            navigation.segue(.taskDetails(task))
        } label: {
            TaskCell(task: task) {
                Task {
                    await viewModel.toggleIsComplete(for: task)
                    await getTasks()
                }
            }
        }
    }
    
    func getTasks() async {
        if selection == .completed {
            await viewModel.getCompletedTasks()
        } else {
            await viewModel.getTasks()
        }
    }
    
    enum Selection: Int, Identifiable, Equatable {
        case date
        case priority
        case completed
        
        var id: Int { rawValue }
    }
}
