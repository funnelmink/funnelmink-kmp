//
//  LabeledRow.swift
//  iosApp
//
//  Created by Jared Warren on 2/17/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import SwiftUI

struct LabeledRow: View {
    let name: String
    let value: String
    var imageName: String?
    var valueColor: Color = .primary
    var body: some View {
        HStack {
            Text(name)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            if let imageName = imageName {
                Label(value, systemImage: imageName)
                    .foregroundColor(valueColor)
            } else {
                Text(value)
                    .foregroundStyle(valueColor)
            }
        }
    }
}
