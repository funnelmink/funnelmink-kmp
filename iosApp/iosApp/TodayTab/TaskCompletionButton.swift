//
//  TaskCompletionButton.swift
//  iosApp
//
//  Created by Jared Warren on 1/15/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Shared
import SwiftUI

struct TaskCompletionButton: View {
    let task: ScheduleTask
    let onTap: () -> Void
    var body: some View {
        Button {
            onTap()
        } label: {
            ZStack {
                Rectangle()
                    .fill(task.priority.priorityColor.opacity(0.24))
                Rectangle()
                    .stroke(task.priority.priorityColor, lineWidth: 2)
                if task.isComplete {
                    Rectangle()
                        .fill(task.priority.priorityColor)
                    Image(systemName: "checkmark")
                        .foregroundStyle(.white)
                        .font(.subheadline.bold())
                }
            }
            .frame(width: 26, height: 26)
        }
        .padding(.trailing, 4)
        .frame(height: 44)
    }
}
