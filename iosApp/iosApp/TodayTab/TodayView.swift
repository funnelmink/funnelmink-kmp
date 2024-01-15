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
    
    @AppStorage(.storage.todaySortOrder) var sortOrder: SortOrder = .date
    @AppStorage(.storage.todayIsSearchable) var isSearchable = false
    
    @ViewBuilder
    var body: some View {
        ZStack {
            switch (isSearchable, viewModel.displayCompletedTasks) {
            case (true, true): searchableCompleted
            case (false, true): vanillaCompleted
                
            case (true, false): searchableList
            case (false, false): vanillaList
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    addTaskFAB
                }
            }
        }
        .tint(.primary)
        .scrollIndicators(.never)
        .navigationTitle("Tasks")
        .task {
            await viewModel.getTasks()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        viewModel.toggleDisplayCompletedTasks()
                    } label: {
                        if viewModel.displayCompletedTasks {
                            Label("Show completed tasks", systemImage: "checkmark")
                        } else {
                            Text("Show completed tasks")
                        }
                    }
                    Button {
                        isSearchable.toggle()
                    } label: {
                        if isSearchable {
                            Label("Display search bar", systemImage: "checkmark")
                        } else {
                            Text("Display search bar")
                        }
                    }
                } label: {
                    Label("Options", systemImage: "ellipsis.circle")
                }
            }
            
            ToolbarItem(placement: .principal) {
                Picker("Sort Order", selection: $sortOrder) {
                    Text("By Date").tag(SortOrder.date)
                    Text("By Priority").tag(SortOrder.priority)
                }
                .pickerStyle(.segmented)
            }
        }
    }
    
    var tasksByDate: some View {
        ForEach(viewModel.tasksByDateSearchResults.keys.sorted(), id: \.self) { section in
            Section(header: Text(section)) {
                ForEach(viewModel.tasksByDateSearchResults[section] ?? [], id: \.id) { task in
                    Button {
                        navigation.presentSheet(.editTask(task))
                    } label: {
                        TaskCell(task: task) {
                            Task {
                                await viewModel.toggleIsComplete(for: task)
                            }
                        }
                    }
                }
            }
        }
    }
    
    var tasksByPriority: some View {
        ForEach(viewModel.tasksByPrioritySearchResults.keys.sorted(by: >), id: \.self) { section in
            Section(header: Text("Priority \(section)")) {
                ForEach(viewModel.tasksByPrioritySearchResults[section] ?? [], id: \.id) { task in
                    Button {
                        navigation.presentSheet(.editTask(task))
                    } label: {
                        TaskCell(task: task) {
                            Task {
                                await viewModel.toggleIsComplete(for: task)
                            }
                        }
                    }
                }
            }
        }
    }
    
    var addTaskFAB: some View {
        Button {
            navigation.presentSheet(.createTask)
        } label: {
            Image(systemName: "plus")
                .resizable()
                .frame(width: 24, height: 24)
                .padding()
                .foregroundStyle(.white)
                .background(LoginBackgroundGradient())
                .clipShape(Circle())
        }
        .padding()
    }
    
    var vanillaList: some View {
        List {
            switch sortOrder {
            case .date: tasksByDate
            case .priority: tasksByPriority
            }
        }
    }
    
    var searchableList: some View {
        List {
            switch sortOrder {
            case .date: tasksByDate
            case .priority: tasksByPriority
            }
        }
        .searchable(text: $viewModel.searchText)
    }
    
    var vanillaCompleted: some View {
        List {
            ForEach(viewModel.completedTasksSearchResults, id: \.id) { task in
                Button {
                    navigation.presentSheet(.editTask(task))
                } label: {
                    TaskCell(task: task) {
                        Task {
                            await viewModel.toggleIsComplete(for: task)
                        }
                    }
                }
            }
        }
    }
    
    var searchableCompleted: some View {
        List {
            ForEach(viewModel.completedTasksSearchResults, id: \.id) { task in
                Button {
                    navigation.presentSheet(.editTask(task))
                } label: {
                    TaskCell(task: task) {
                        Task {
                            await viewModel.toggleIsComplete(for: task)
                        }
                    }
                }
            }
        }
        .searchable(text: $viewModel.searchText)
    }
    
    enum SortOrder: Int, Identifiable {
        case date
        case priority
        
        var id: Int { rawValue }
    }
}
