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
                        .stroke(Gradient(colors: [.mint, .teal, .blue]), lineWidth: 10)
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
                    guard let phoneNumber = contact.phoneNumbers.first else { return }
                    makeCall(phoneNumber: phoneNumber)
                }, label: {
                    CustomCell(title: "Phone", subtitle: contact.phoneNumbers.first, icon: "phone" ,cellType: .iconAction)
                        .padding()
                })
                .foregroundStyle(.primary)
                Button(action: {
                    guard let email = contact.emails.first else { return }
                    prepareEmail(emailAddress: email)
                }, label: {
                    CustomCell(title: "Email", subtitle: contact.emails.first, icon: "envelope" ,cellType: .iconAction)
                        .padding()
                })
                .foregroundStyle(.primary)
                Button(action: {
                    navigateToAddress(address: "2236 N 1060 W, Provo, UT 84604")
                }, label: {
                    CustomCell(title: "Address", subtitle: "Default Address (no field for address on backend)", icon: "arrow.merge" ,cellType: .iconAction)
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
    ContactView(
        contact: Contact(
            id: "",
            firstName: "Jeremy",
            lastName: "Warren",
            emails: ["jeddynwarren@gmail.com"],
            phoneNumbers: ["(801) 226-8345"],
            companyName: "Funnelmink",
            isOrganization: false,
            latitude: 38.465636,
            longitude: -66.813608,
            street1: "891 N 800 E",
            street2: nil,
            city: "Orem",
            state: "UT",
            country: "US",
            zip: "84097"
        )
    )
}
