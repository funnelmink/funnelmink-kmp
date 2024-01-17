//
//  CustomAccordion.swift
//  FunnelMinkViews
//
//  Created by Jeremy Warren on 12/26/23.
//

import SwiftUI

struct CustomAccordion: View {
    @State var isExpanded: Bool
    var title: String
    var description: String
    var icon: String?
    
    var body: some View {
            DisclosureGroup(isExpanded: $isExpanded) {
                Text(description)
                    .padding()
            } label: {
                if let icon {
                    Image(systemName: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
                    Text(title)
                        .fontWeight(.bold)
                        .padding()
            }
            .background(Color.white)
            .cornerRadius(10)
            .disclosureGroupStyle(CustomDisclosureGroupStyle())
            .shadow(radius: 2)
        }
}

#Preview {
    VStack {
        CustomAccordion(isExpanded: false, title: "How do I subscribe?", description: "Tap My Account in the settings tab to manage your subscriptions", icon: "person.fill")
        CustomAccordion(isExpanded: false, title: "Frequently Asked Questions", description: "Find answers to common questions about our service.", icon: "questionmark")
        CustomAccordion(isExpanded: false, title: "Contact Support", description: "Need help? Reach out to our support team via email or phone.")
    }
}


struct CustomDisclosureGroupStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            withAnimation(.default) {
                configuration.isExpanded.toggle()
            }
        } label: {
            VStack {
                HStack {
                    configuration.label
                    Spacer()
                    Image(systemName: configuration.isExpanded ? "chevron.up" : "chevron.down")
                }
                .padding()
                .cornerRadius(8)
                
                if configuration.isExpanded {
                    configuration.content
                        .transition(.slide)
                        .background(Color.gray.opacity(0.1))
                }
            }
            .foregroundStyle(.black)
        }
    }
}
