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
    var contact: Contact
    
    var body: some View {
        VStack {
            ZStack {
                Circle().stroke(lineWidth: 5).frame(width: 150,height: 150)
                Text(contact.name)
            }
            Text(contact.jobTitle ?? "")
                .padding()
        }
    }
}

#Preview {
    ContactView(contact: Contact(id: "", name: "Jeremy Warren", emails: ["jeddynwarren@gmail.com"], phoneNumbers: ["(801) 226-8345"], jobTitle: "Funnelmink"))
}
