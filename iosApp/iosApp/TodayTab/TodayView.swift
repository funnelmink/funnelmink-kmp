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
        ScrollView {
            ForEach(viewModel.tasks.keys.sorted(), id: \.self) { date in
                Section(header: Text(date)) {
                    ForEach(viewModel.tasks[date] ?? [], id: \.id) { task in
                        Button {
                            navigation.presentSheet(.editTask(task))
                        } label: {
                            TaskCell(task: task)
                        }
                    }
                }
            }
        }
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
