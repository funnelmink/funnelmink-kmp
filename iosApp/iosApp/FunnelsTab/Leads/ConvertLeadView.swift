//
//  ConvertLeadView.swift
//  iosApp
//
//  Created by Jared Warren on 2/15/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Shared
import SwiftUI

struct ConvertLeadView: View {
    @EnvironmentObject var navigation: Navigation
    
    let lead: Lead
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button("Cancel") {
                    navigation.dismissModal()
                }
                Spacer()
            }
            Button {
                // the onDismiss here is a little hacky. assumes that we're coming from LeadDetailView and that it will want to be refreshed
                navigation.modalSheet(.closeRecord(type: .lead, id: lead.id), onDismiss: navigation._onModalDismiss)
            } label: {
                Color
                    .secondary
                    .opacity(0.24)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        VStack {
                            Text("Close as Lost")
                                .font(.headline)
                            Text("This Lead is not interested in our product")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(.primary)
            }
            cardButton(
                title: "Convert to Account",
                subtitle: "We've established a relationship with this Lead" ,
                conversionResult: .account
            )
            cardButton(
                title: "Convert to Account + Opportunity",
                subtitle: "We've established a relationship and are actively pursuing a sale",
                conversionResult: .accountAndOpportunity
            )
        }
        .padding()
    }
    
    func cardButton(title: String, subtitle: String, conversionResult: LeadClosedResult) -> some View {
        AsyncWarningAlertButton(warningMessage: "\(title)?") {
            do {
                try await Networking.api.convertLead(id: lead.id, result: conversionResult, body: .init(reason: nil))
                navigation.dismissModal()
                Toast.success("Lead closed")
            } catch {
                Toast.warn(error)
            }
        } label: {
            Color
                .secondary
                .opacity(0.24)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay {
                    VStack {
                        Text(title)
                            .font(.headline)
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .tint(.primary)
        }
    }
}

#Preview {
    ConvertLeadView(
        lead: TestData.lead
    )
    .withPreviewDependencies()
}
