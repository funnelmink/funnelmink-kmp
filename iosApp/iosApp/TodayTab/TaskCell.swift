//
//  TaskCell.swift
//  iosApp
//
//  Created by Jared Warren on 1/11/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Shared
import SwiftUI

struct TaskCell: View {
    let task: ScheduleTask
    let onTapIsComplete: () -> Void
    
    var body: some View {
        HStack {
            TaskCompletionButton(task: task, onTap: onTapIsComplete)
            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.headline)
                if let body = task.body, !body.isEmpty {
                    Text(body)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 44)
        }
        .lineLimit(1)
        .frame(height: 44)
    }
}

#Preview {
    List {
        TaskCell(
            task: ScheduleTask(
                id: "a",
                title: "Window and mail",
                body: nil,
                priority: 1,
                isComplete: false,
                scheduledDate: "2021-01-11"
            )
        ){}
        TaskCell(
            task: ScheduleTask(
                id: "b",
                title: "funnelmink daily update",
                body: "talk about some freaking thing",
                priority: 2,
                isComplete: false,
                scheduledDate: "2021-01-11"
            )
        ){}
        TaskCell(
            task: ScheduleTask(
                id: "c",
                title: "funnelmink daily update",
                body: "talk about some freaking thing",
                priority: 3,
                isComplete: true,
                scheduledDate: "2021-01-11"
            )
        ){}
        TaskCell(
            task: ScheduleTask(
                id: "d",
                title: "funnelmink daily update",
                body: "talk about some freaking thing",
                priority: 0,
                isComplete: false,
                scheduledDate: "2021-01-11"
            )
        ){}
    }
}
