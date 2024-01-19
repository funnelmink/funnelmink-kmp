//
//  TimelineView.swift
//  iosApp
//
//  Created by Jeremy Warren on 1/18/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import SwiftUI

struct TimelineView: View {
    
    var tasks: [TimelineTask]
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                // Vertical line
                Rectangle()
                    .frame(width: 2)
                    .foregroundColor(.gray)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
                // Task items
                VStack(alignment: .center, spacing: 30) {
                    ForEach(Array(tasks.enumerated()), id: \.element.title) { (index, task) in
                        HStack {
                            if index % 2 == 1 {
                                Circle()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(task.didComplete ? .green : .red)
                                
                                VStack(alignment: .leading) {
                                    Text(task.title)
                                        .font(.headline)
                                    Text("Date: \(task.date, formatter: dateFormatter)")
                                        .font(.subheadline)
                                    Text("Completed: \(task.didComplete ? "Yes" : "No")")
                                        .font(.subheadline)
                                }
                            }
                        }
                        .offset(x: 68.5)
                        HStack {
                            if index % 2 != 1 {
                                VStack(alignment: .leading) {
                                    Text(task.title)
                                        .font(.headline)
                                    Text("Date: \(task.date, formatter: dateFormatter)")
                                        .font(.subheadline)
                                    Text("Completed: \(task.didComplete ? "Yes" : "No")")
                                        .font(.subheadline)
                                    
                                    
                                }
                                Circle()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(task.didComplete ? .green : .red)
                                
                            }
                        }
                        .offset(x: -67.5)
                    }
                }
            }
        }
    }
}

struct TimelineTask {
    let title: String
    let date: Date
    let didComplete: Bool
}


#Preview {
    TimelineView(tasks: [TimelineTask(title: "Upsell", date: Date(), didComplete: false),
                         TimelineTask(title: "Setting up", date: Date(), didComplete: true),
                         TimelineTask(title: "Sale", date: Date(), didComplete: true),
                         TimelineTask(title: "Phone Call", date: Date(), didComplete: true),
                         TimelineTask(title: "Second Contact", date: Date(), didComplete: false),
                         TimelineTask(title: "First Contact", date: Date(), didComplete: true)
                        ])
}
