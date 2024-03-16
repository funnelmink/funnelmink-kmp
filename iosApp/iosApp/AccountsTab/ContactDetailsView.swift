//
//  ContactDetailsView.swift
//  iosApp
//
//  Created by Jeremy Warren on 2/17/24.
//  Copyright © 2024 FunnelMink. All rights reserved.
//

import SwiftUI
import Shared

struct ContactDetailsView: View {
    @EnvironmentObject var navigation: Navigation
    let contact: AccountContact
    
    private func makeCall(phoneNumber: String) {
        guard let url = URL(string: "tel://\(phoneNumber)"),
              UIApplication.shared.canOpenURL(url) else {
            print("Cannot make this call")
            return
        }
        
        UIApplication.shared.open(url)
    }
    
    private func prepareEmail(emailAddress: String) {
        
        func mailAppURL() -> URL? {
            return URL(string: "mailto:\(emailAddress)")
        }
        
        func gmailAppURL() -> URL? {
            return URL(string: "googlegmail:///co?to=\(emailAddress)")
        }
        
        let mailURL = mailAppURL()
        let gmailURL = gmailAppURL()
        
        let canOpenGmail = UIApplication.shared.canOpenURL(gmailURL!)
        
        let mailAppAction = UIAlertAction(title: "Mail", style: .default) { _ in
            if let url = mailURL, UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                Logger.description()
            }
        }
        
        let gmailAppAction = UIAlertAction(title: "Gmail", style: .default) { _ in
            if let url = gmailURL, canOpenGmail {
                UIApplication.shared.open(url)
            } else {
                Logger.description()
            }
        }
        
        let actionSheet = UIAlertController(title: "Send Email", message: "Choose an email app", preferredStyle: .actionSheet)
        actionSheet.addAction(mailAppAction)
        if canOpenGmail {
            actionSheet.addAction(gmailAppAction)
        }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        UIApplication.shared.windows.first?.rootViewController?.present(actionSheet, animated: true, completion: nil)
    }

    var body: some View {
        VStack {
            Text("Contact Info")
                .bold()
                .font(.headline)
                .padding()

            HStack {
                Text("Name")
                    .bold()
                Spacer()
                Text(contact.name ?? "")
            }
            .padding()

            HStack {
                Text("Email")
                    .bold()
                Spacer()
                Button(action: {
                    prepareEmail(emailAddress: contact.email ?? "")
                }) {
                    Text(contact.email ?? "")
                        .foregroundColor(.blue)
                        .underline()
                }
            }
            .padding()

            HStack {
                Text("Phone")
                    .bold()
                Spacer()
                Button(action: {
                    makeCall(phoneNumber: contact.phone ?? "")
                }) {
                    Text(contact.phone ?? "")
                        .foregroundColor(.blue)
                        .underline()
                }
            }
            .padding()

            HStack {
                Text("Notes")
                    .bold()
                Spacer()
                Text(contact.notes ?? "")
            }
            .padding()

            Button("Dismiss") {
                navigation.dismissModal()
            }
            .padding()

        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding()
    }
}

#Preview {
    ContactDetailsView(contact: TestData.accountContact)
}
