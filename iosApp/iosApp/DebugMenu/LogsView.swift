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
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
            ForEach(Utilities.shared.logger.getLogs(), id: \.timestamp) { log in
                    Color.gray.frame(height: 0.5)
                        .padding(.horizontal)
                    Text(log.message)
                        .foregroundStyle(log.level == .info ? .white : log.level == .warn ? .yellow : .red)
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    LogsView()
}
