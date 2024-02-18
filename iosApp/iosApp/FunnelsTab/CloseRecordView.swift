//
//  CloseRecordView.swift
//  iosApp
//
//  Created by Jared Warren on 2/17/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Shared
import SwiftUI

struct CloseRecordView: View {
    let recordType: FunnelType
    let recordID: String
    var body: some View {
        VStack {
            
            AsyncButton {
                switch recordType {
                case .case:
                    try await Networking.api.closeCase(id: recordID)
                case .lead:
                    try await Networking.api.convertLead(id: recordID, result: .lost)
                case .opportunity:
                    <#code#>
                }
            } label: {
                Text("Close")
            }

        }
    }
}

#Preview {
    CloseRecordView(
        recordType: .case,
        recordID: ""
    )
    .withPreviewDependencies()
}
