//
//  HomeView.swift
//  iosApp
//
//  Created by Jared Warren on 10/19/23.
//  Copyright © 2023 FunnelMink. All rights reserved.
//

import SwiftUI

struct TodayView: View {
    @EnvironmentObject var nav: Navigation
    
    let tasks: [CalendarTask] = [
//        .init(id: "a", priority: 1, title: "Task 1", body: "This is a task", scheduledDate: nil),
//        .init(id: "b", priority: 2, title: "Task 2", body: "This is a task", scheduledDate: nil),
//        .init(id: "c", priority: 3, title: "Task 3", body: "This is a task", scheduledDate: nil),
    ]
    var body: some View {
        Text("Coming soon!")
//        ScrollView {
//            ForEach(tasks) { task in
//                TaskCell(task: task)
//            }
//        }
//        .scrollIndicators(.never)
        .navigationTitle("Today")
    }
}

#Preview {
    TodayView()
}


struct TaskCell: View {
    let task: CalendarTask
    var body: some View {
        VStack(alignment: .leading) {
            Text(task.title)
                .font(.title2)
                .fontWeight(.semibold)
            Text(task.body)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

struct CalendarTask: Codable, Identifiable {
    let id: String
    let priority: Int
    let title: String
    let body: String
    let scheduledDate: Date?
}
