//
//  AccountView.swift
//  iosApp
//
//  Created by Jeremy Warren on 1/13/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import SwiftUI
import Shared
import UIKit

struct AccountView: View {
    @EnvironmentObject var nav: Navigation
    @StateObject var viewModel = AccountsViewModel()
    @State private var isAnimating: Bool = false
    @State private var showingActionSheet = false
    
    var account: Account
    var accountFullAddress: String {
        return ("\(account.address ?? ""), \(account.city ?? ""), \(account.country ?? "")")
    }
    var initials: String {
        
        if let initial = account.name.first {
            return String(initial)
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
    
    private func navigateToAddress(address: String) {
        
        guard let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Invalid address")
            return
        }
        
        func appleMapsURL() -> URL? {
            return URL(string: "http://maps.apple.com/?daddr=\(encodedAddress)")
        }
        
        func googleMapsURL() -> URL? {
            return URL(string: "comgooglemaps://?daddr=\(encodedAddress)&directionsmode=driving")
        }
        
        let appleMapsURL = appleMapsURL()
        let googleMapsURL = googleMapsURL()
        
        let canOpenGoogleMaps = UIApplication.shared.canOpenURL(googleMapsURL!)
        
        let appleMapsAction = UIAlertAction(title: "Apple Maps", style: .default) { _ in
            if let url = appleMapsURL, UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                print("Cannot open Apple Maps")
            }
        }
        
        let googleMapsAction = UIAlertAction(title: "Google Maps", style: .default) { _ in
            if let url = googleMapsURL, canOpenGoogleMaps {
                UIApplication.shared.open(url)
            } else {
                print("Cannot open Google Maps")
            }
        }
        
        let actionSheet = UIAlertController(title: "Navigate", message: "Choose a Maps app", preferredStyle: .actionSheet)
        actionSheet.addAction(appleMapsAction)
        if canOpenGoogleMaps {
            actionSheet.addAction(googleMapsAction)
        }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // NOTE: Update this line to present the action sheet in your view context
        UIApplication.shared.windows.first?.rootViewController?.present(actionSheet, animated: true, completion: nil)
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
            Text(account.name)
                .bold()
                .font(.title)
        }
        Spacer()
        ScrollView {
            Button(action: {
                showingActionSheet = true
            }, label: {
                CustomCell(title: "Phone", subtitle: account.phone, icon: "phone" ,cellType: .iconAction)
                    .padding()
            })
            .foregroundStyle(.primary)
            .actionSheet(isPresented: $showingActionSheet) {
                ActionSheet(
                    title: Text("Account"),
                    message: Text("Call \(account.phone ?? "")?"),
                    buttons: [
                        .default(Text("Call")) {
                            guard let phoneNumber = account.phone else { return }
                            makeCall(phoneNumber: phoneNumber)
                        },
                        .cancel()
                    ]
                )
            }
            Button(action: {
                // present a banner to send an email
            }, label: {
                CustomCell(title: "Email", subtitle: account.email, icon: "envelope" ,cellType: .iconAction)
                    .padding()
            })
            .foregroundStyle(.primary)
            Button(action: {
                // present a banner to route to an address
            }, label: {
                CustomCell(title: "Address", subtitle: accountFullAddress, icon: "arrow.merge" ,cellType: .iconAction)
                    .padding()
            })
            .foregroundStyle(.primary)
            Button(action: {
                nav.modalSheet(.createContact)
            }, label: {
                CustomCell(title: "Create Contact", subtitle: "Add contact to account", icon: "plus" ,cellType: .iconAction)
                    .padding()
            })
            .foregroundStyle(.primary)
            VStack(alignment: .leading) {
                Text("Account Notes")
                    .bold()
                Text(account.notes ?? "")
                    .padding(.vertical)
                    .padding(.horizontal)
                    .font(.footnote)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke()
                    }
            }
            .padding(.horizontal)
            .padding(.vertical)
        }
        .padding()
    }
}

#Preview {
    AccountView(account: Account(id: "id", address: "street address", city: "City", country: "Country", createdAt: "Date created", email: "email", latitude: 123.123, leadID: "LeadID?", longitude: 123.123, name: "Account Name", notes: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum", phone: "phone number here", state: "STATE", type: .organization, updatedAt: "UpdatedAt?", zip: "Zip Code"))
}
