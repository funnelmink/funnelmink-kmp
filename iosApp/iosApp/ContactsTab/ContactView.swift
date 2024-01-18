//
//  ContactView.swift
//  iosApp
//
//  Created by Jeremy Warren on 1/13/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import SwiftUI
import Shared

struct ContactView: View {
    @EnvironmentObject var nav: Navigation
    @StateObject var viewModel = ContactsViewModel()
    @State private var isAnimating: Bool = false
    var contact: Contact
    var initials: String {
        let fullName = contact.name
        let nameComponents = fullName.split(separator: " ")
        
        if let firstNameInitial = nameComponents.first?.first,
           let lastNameInitial = nameComponents.last?.first {
            return String(firstNameInitial) + String(lastNameInitial)
        } else {
            return ""
        }
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
            Text(contact.name)
                .bold()
                .font(.title)
            Text(contact.jobTitle ?? "")
                .foregroundStyle(.secondary)
        }
        Spacer()
        ScrollView {
            CustomCell(title: "Phone", subtitle: contact.phoneNumbers?.first, icon: "phone" ,cellType: .iconAction)
                .padding()
            CustomCell(title: "Email", subtitle: contact.emails?.first, icon: "envelope" ,cellType: .iconAction)
                .padding()
            CustomCell(title: "Address", subtitle: "891 N 800 E, Orem, UT              ", icon: "arrow.merge" ,cellType: .iconAction)
                .padding()
        }
        .padding()
    }
}


#Preview {
    ContactView(contact: Contact(id: "", name: "Jeremy Warren", emails: ["jeddynwarren@gmail.com"], phoneNumbers: ["(801) 226-8345"], jobTitle: "Funnelmink"))
}
