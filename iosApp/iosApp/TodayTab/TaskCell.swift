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
    
    private var priorityColor: Color {
        switch task.priority {
        case 1: return .blue
        case 2: return .purple
        case 3: return .red
        default: return .gray
        }
    }
    
    var body: some View {
        HStack {
            Button {
                onTapIsComplete()
            } label: {
                ZStack {
                    Circle()
                        .fill(priorityColor.opacity(0.24))
                    Circle()
                        .stroke(priorityColor, lineWidth: 2)
                    if task.isComplete {
                        Circle()
                            .fill(priorityColor)
                        Image(systemName: "checkmark")
                            .foregroundStyle(.white)
                            .font(.caption.bold())
                    }
                }
                .frame(width: 30)
            }
            .padding(.trailing, 4)
            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.headline)
                if let body = task.body {
                    Text(body)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .lineLimit(1)
        .frame(minHeight: 44)
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
