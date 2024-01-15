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
    
    @ViewBuilder
    var body: some View {
        List {
            ForEach(viewModel.tasks.keys.sorted(), id: \.self) { section in
                Section(header: Text(section)) {
                    ForEach(viewModel.tasks[section] ?? [], id: \.id) { task in
                        Button {
                            navigation.presentSheet(.editTask(task))
                        } label: {
                            TaskCell(task: task) {
                                Task {
                                    await viewModel.toggleIsComplete(for: task, in: section)
                                }
                            }
                        }
                    }
                }
            }
        }
        .tint(.primary)
        .scrollIndicators(.never)
        .navigationTitle("Today")
        .task {
            await viewModel.getTasks()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    navigation.presentSheet(.createTask)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}
