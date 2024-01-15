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
    @State var sortOrder: SortOrder = .date
    @State var searchText = ""
    @State var isSearchable = false
    
    @ViewBuilder
    var body: some View {
        ZStack {
            if isSearchable {
                searchableList
            } else {
                vanillaList
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
            // task options menu
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
            
            // sort segment picker
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
        ForEach(viewModel.tasksByDate.keys.sorted(), id: \.self) { section in
            Section(header: Text(section)) {
                ForEach(viewModel.tasksByDate[section] ?? [], id: \.id) { task in
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
        ForEach(viewModel.tasksByPriority.keys.sorted(by: >), id: \.self) { section in
            Section(header: Text("Priority \(section)")) {
                ForEach(viewModel.tasksByPriority[section] ?? [], id: \.id) { task in
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
        .searchable(text: $searchText)
    }
    
    enum SortOrder: Int, Identifiable {
        case date
        case priority
        
        var id: Int { rawValue }
    }
}
