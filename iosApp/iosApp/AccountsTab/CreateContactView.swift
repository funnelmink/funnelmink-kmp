//
//  CreateContactView.swift
//  iosApp
//
//  Created by Jeremy Warren on 2/13/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import SwiftUI
import Shared

struct CreateContactView: View {
    var account: Account
    @State var name: String = ""
    @State var phoneNumber: String = ""
    @State var email: String = ""
    @State var notes: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Create Contact")
                    .font(.largeTitle)
                CustomTextField(text: $name, placeholder: "Contact Name", style: .text)
                CustomTextField(text: $name, placeholder: "Contact Phone Number", style: .phone)
                CustomTextField(text: $name, placeholder: "Email", style: .text)


            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    CreateContactView(account: Account(id: "id", address: "street address", city: "City", country: "Country", createdAt: "Date created", email: "email", latitude: 123.123, leadID: "LeadID?", longitude: 123.123, name: "Account Name", notes: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum", phone: "phone number here", state: "STATE", type: .organization, updatedAt: "UpdatedAt?", zip: "Zip Code"))
}
