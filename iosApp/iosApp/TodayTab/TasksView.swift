//
//  HomeView.swift
//  iosApp
//
//  Created by Jared Warren on 10/19/23.
//  Copyright © 2023 FunnelMink. All rights reserved.
//

import Shared
import SwiftUI

struct TasksView: View {
    @EnvironmentObject var navigation: Navigation
    @StateObject var viewModel = TodayViewModel()
    
    @AppStorage(.storage.todayPickerSelection) var selection: Selection = .date
    
    let backgroundForButton = Color(hex: "F2F2F7")
    
    @ViewBuilder
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(Selection.allCases, id: \.self) { newSelection in
                    Button(action: {
                        selection = newSelection
                    }) {
                        Text(newSelection.name)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(selection == newSelection ? Color.teal : backgroundForButton)
                            .foregroundColor(selection == newSelection ? .white : .secondary)
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
        }
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
            ToolbarItem(placement: .navigationBarLeading) {
                // Your custom leading items here, if any.
            }
            ToolbarItemGroup(placement: .principal) {
                NavigationSearchView()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                // Your custom trailing items here, if any.
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
    
    enum Selection: Int, Identifiable, Equatable, CaseIterable {
        case date
        case priority
        case completed
        
        var id: Int { rawValue }
        var name: String {
            switch self {
            case .date: return "Date"
            case .priority: return "Priority"
            case .completed: return "Completed"
            }
        }
    }
}
