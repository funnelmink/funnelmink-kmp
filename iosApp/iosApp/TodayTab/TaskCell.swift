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
    let task: TaskRecord
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
                        .lineLimit(1)
                }
            }
            .frame(minHeight: 44)
        }
        .lineLimit(5)
        .frame(minHeight: 44)
    }
}
