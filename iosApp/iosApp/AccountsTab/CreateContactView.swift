//
//  CreateContactView.swift
//  iosApp
//
//  Created by Jeremy Warren on 2/13/24.
//  Copyright © 2024 FunnelMink. All rights reserved.
//

import SwiftUI
import Shared

struct CreateContactView: View {
    
    @EnvironmentObject var nav: Navigation
    var accountID: String
    @State var name: String = ""
    @State var jobTitle: String = ""
    @State var phoneNumber: String = ""
    @State var email: String = ""
    @State var notes: String = ""
    
    func addContactToAccount() async {
        do {
            let _ = try await Networking.api.createAccountContact(accountID: accountID, body: CreateAccountContactRequest(name: name, email: email, phone: phoneNumber, jobTitle: jobTitle, notes: notes))
            nav.dismissModal()
        } catch {
            Toast.warn("Could not add contact to account")
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Button(action: {
                        nav.dismissModal()
                    }, label: {
                        Text("Cancel")
                    })
                    Spacer()
                    Text("Create Contact")
                        .font(.largeTitle)
                    Spacer()
                    AsyncButton(action: {
                        await addContactToAccount()
                    }, label: {
                        Text("Done")
                    })
                }
                CustomTextField(text: $name, placeholder: "Contact Name", style: .text)
                CustomTextField(text: $jobTitle, placeholder: "Job Title", style: .text)
                CustomTextField(text: $phoneNumber, placeholder: "Contact Phone Number", style: .phone)
                CustomTextField(text: $email, placeholder: "Contact Email", style: .text)
                VStack(alignment: .leading) {
                    Text("Contact Notes")
                        .font(.system(size: 20).weight(.semibold))
                    TextEditor(text: $notes)
                        .frame(width: 350, height: 150)
                        .border(.secondary)
                }
            }
            .padding(.horizontal)
        }
        .logged()
    }
}

#Preview {
    CreateContactView(accountID: TestData.account.id)
}
