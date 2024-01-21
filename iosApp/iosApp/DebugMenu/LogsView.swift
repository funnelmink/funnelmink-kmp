//
//  LogsView.swift
//  iosApp
//
//  Created by Jared Warren on 1/18/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Shared
import SwiftUI

struct LogsView: View {
    @State var logs = Utilities.shared.logger.getLogs()
    var body: some View {
        ScrollViewReader { o_o in
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(logs, id: \.id) { log in
                        Color.gray.frame(height: 0.5)
                            .padding(.horizontal)
                        Text(log.message)
                            .foregroundStyle(
                                log.level == .info ? .white :
                                    log.level == .view ? .cyan :
                                    log.level == .warn ? .yellow : .red
                            )
                            .font(.caption)
                            .id(log.id)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .onAppear {
                o_o.scrollTo(logs.last?.id)
            }
        }
    }
}

#Preview {
    LogsView()
}

extension LogEntry {
    var id: String { "\(timestamp)\(message)" }
}
