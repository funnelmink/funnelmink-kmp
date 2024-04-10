//
//  AccountDetailsView.swift
//  iosApp
//
//  Created by Jeremy Warren on 3/27/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import SwiftUI
import Shared

struct AccountDetailsView: View {
    @EnvironmentObject var nav: Navigation
    @StateObject var viewModel = AccountsViewModel()
    @State private var isAnimating: Bool = false
    @State private var showingActionSheet = false
    @State var account: Account
    var accountFullAddress: String {
        return ("\(account.address), \(account.city), \(account.state), \(account.country)")
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
        List {
            HStack(alignment: .center, spacing: 25) {
                ZStack {
                    Circle()
                        .stroke(Gradient(colors: [.blue, .teal, .mint]), lineWidth: 8)
                        .frame(width: 100, height: 100)
                    
                    Text(initials)
                        .bold().font(.system(size: 40))
                }
                VStack(alignment: .leading, spacing: 15) {
                    Text(account.name)
                        .bold()
                        .font(.title)
                    
                    if !account.email.isEmpty {
                        Button(action: {
                            prepareEmail(emailAddress: account.email)
                        }, label: {
                            Text(account.email)
                                .foregroundColor(.secondary)
                                .font(.headline)
                        })
                    }
                    
                    if !account.phone.isEmpty {
                        Button(action: {
                            showingActionSheet = true
                        }, label: {
                            Text(account.phone)
                                .foregroundColor(.secondary)
                                .font(.headline)
                        })
                        .foregroundStyle(.primary)
                        .actionSheet(isPresented: $showingActionSheet) {
                            ActionSheet(
                                title: Text("Account"),
                                message: Text("Call \(account.phone)?"),
                                buttons: [
                                    .default(Text("Call")) {
                                        makeCall(phoneNumber: account.phone)
                                    },
                                    .cancel()
                                ]
                            )
                        }
                    }
                }
            }
            
            if !account.cases.isEmpty {
                Section(header: Text("Cases").font(.headline), content: {
                    ForEach(account.cases, id: \.self) { caseRecord in
                        Button {
                            nav.segue(.caseDetails(caseRecord: caseRecord))
                        } label: {
                            CustomCell(title: caseRecord.name, cellType: .navigation)
                        }
                        
                    }
                })
                .padding(.horizontal)
            }
            
            if !account.opportunities.isEmpty {
                Section("Opportunities") {
                    ForEach(account.opportunities, id: \.self) { opportunity in
                        Button {
                            nav.segue(.opportunityDetails(opportunity: opportunity))
                        } label: {
                            CustomCell(title: opportunity.name, cellType: .navigation)
                        }
                        
                    }
                }
                .padding(.horizontal)
            }
            
            if !account.contacts.isEmpty {
                Section(header: Text("Contacts").font(.title3) , content: {
                    ForEach(account.contacts, id: \.self) { contact in
                        Button {
                            nav.presentAlert(.contactDetails(contact))
                        } label: {
                            CustomCell(title: contact.name, cellType: .navigation)
                                .foregroundColor(.secondary)
                        }
                    }
                })
                .padding(.horizontal)
            }
        }
        .loggedTask {
            do {
                account = try await Networking.api.getAccountDetails(id: account.id)
            } catch {
                Toast.error("Unable to get account details")
            }
        }

    }
}

#Preview {
    AccountDetailsView(account: TestData.account)
}
