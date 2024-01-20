//
//  ContactView.swift
//  iosApp
//
//  Created by Jeremy Warren on 1/13/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import SwiftUI
import Shared
import UIKit

struct ContactView: View {
    @EnvironmentObject var nav: Navigation
    @StateObject var viewModel = ContactsViewModel()
    @State private var isAnimating: Bool = false
    @State private var showingActionSheet = false
    @State
    
    var contact: Contact
    var initials: String {
        
        if let firstNameInitial = contact.firstName.first,
           let lastNameInitial = contact.lastName?.first {
            return String(firstNameInitial) + String(lastNameInitial)
        } else {
            return ""
        }
    }
    
     private func makeCall(phoneNumber: String) {
        guard let url = URL(string: "tel://\(phoneNumber)"),
              UIApplication.shared.canOpenURL(url) else {
            print("Cannot make this call")
            return
        }

        UIApplication.shared.open(url)
    }
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(Gradient(colors: [.blue, .teal, .mint]), lineWidth: 10)
                    .frame(width: 175, height: 175)
                
                Text(initials)
                    .bold().font(.system(size: 80))
            }
            Text(contact.firstName + " " + (contact.lastName ?? ""))
                .bold()
                .font(.title)
            Text(contact.companyName ?? "")
                .foregroundStyle(.secondary)
        }
        Spacer()
        ScrollView {
            Button(action: {
//                guard let phoneNumber = contact.phoneNumbers.first else { return }
                showingActionSheet = true
            }, label: {
                CustomCell(title: "Phone", subtitle: contact.phoneNumbers.first, icon: "phone" ,cellType: .iconAction)
                    .padding()
            })
            .foregroundStyle(.primary)
            .actionSheet(isPresented: $showingActionSheet) {
                        ActionSheet(
                            title: Text("Contact"),
                            message: Text("Call \(contact.phoneNumbers.first ?? "")?"),
                            buttons: [
                                .default(Text("Call")) {
                                    guard let phoneNumber = contact.phoneNumbers.first else { return }
                                    makeCall(phoneNumber: phoneNumber)
                                },
                                .cancel()
                            ]
                        )
                    }
            Button(action: {
                // present a banner to send an email
            }, label: {
                CustomCell(title: "Email", subtitle: contact.emails.first, icon: "envelope" ,cellType: .iconAction)
                    .padding()
            })
            .foregroundStyle(.primary)
            Button(action: {
                // present a banner to route to an address
            }, label: {
                CustomCell(title: "Address", subtitle: "891 N 800 E, Orem, UT              ", icon: "arrow.merge" ,cellType: .iconAction)
                    .padding()
            })
            .foregroundStyle(.primary)
        }
        .padding()
        
        
    }
}

struct ContactEvent {
    
}

#Preview {
    ContactView(contact: Contact(id: "", firstName: "Jeremy", lastName: "Warren", emails: ["jeddynwarren@gmail.com"], phoneNumbers: ["(801) 226-8345"], companyName: "Funnelmink", isOrganization: false))
}
