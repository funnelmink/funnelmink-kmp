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
    var body: some View {
        VStack(alignment: .leading) {
            Text(task.title)
                .font(.title2)
                .fontWeight(.semibold)
            Text(task.body ?? "")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    TaskCell(
        task: ScheduleTask(
            id: "a",
            title: "Test",
            body: "Test",
            priority: 1,
            isComplete: true,
            scheduledDate: "2021-01-11"
        )
    )
}
