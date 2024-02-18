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
    @EnvironmentObject var navigation: Navigation
    let recordType: FunnelType
    let recordID: String
    @State var reason = ""
    var body: some View {
        VStack {
            Text("Close \(recordType.name)")
                .fontWeight(.bold)
            Text("Reason for closure (optional)")
                .foregroundStyle(.secondary)
                .font(.subheadline)
            TextEditor(text: $reason)
                .frame(minHeight: 100)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke()
                        .foregroundStyle(.gray).opacity(0.4)
                }
                .padding(4)
            AsyncButton {
                do {
                    let body = RecordClosureRequest(reason: reason.nilIfEmpty())
                    switch recordType {
                    case .case:
                        _ = try await Networking.api.closeCase(id: recordID, body: body)
                    case .lead:
                        try await Networking.api.convertLead(id: recordID, result: .lost, body: body)
                    case .opportunity:
                        _ = try await Networking.api.closeOpportunity(id: recordID, body: body)
                    }
                    navigation.dismissModal()
                } catch {
                    Toast.warn(error)
                }
            } label: {
                Text("Close")
                    .frame(height: 52)
                    .maxReadableWidth()
                    .background(FunnelminkGradient())
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }

        }
        .padding()
        .logged(info: "\(recordType.typeName) \(recordID)")
    }
}

#Preview {
    CloseRecordView(
        recordType: .case,
        recordID: ""
    )
    .withPreviewDependencies()
}
