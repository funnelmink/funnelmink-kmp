//
//  CreateAccountView.swift
//  iosApp
//
//  Created by Jeremy Warren on 1/13/24.
//  Copyright © 2024 FunnelMink. All rights reserved.
//

import SwiftUI
import Shared

struct CreateAccountView: View {
    @EnvironmentObject var nav: Navigation
    @StateObject var viewModel = AccountsViewModel()
    @State var name = ""
    @State var email: String = ""
    @State var address: String = ""
    @State var phoneNumber: String = ""
    @State var city: String = ""
    @State var state: String = ""
    @State var country: String = ""
    @State var zip: String = ""
    @State var isIndividual: Bool = false
    @State var accountNotes: String = ""
    @State var emails: [String] = []
    @State var phoneNumbers: [String] = []
    
    func addAccount() {
        Task {
            do {
                // TODO: update this to use the new createAccount method
            let createdAccount = try await viewModel.createAccount(
                    name: name,
                    email: email,
                    phone: phoneNumber,
                    latitude: nil,
                    longitude: nil,
                    address: address,
                    city: city,
                    state: state,
                    country: country,
                    zip: zip,
                    notes: accountNotes,
                    leadID: nil
                )
                nav.dismissModal()
                nav.segue(.accountDetailsView(createdAccount))
            } catch {
                Toast.error(error)
            }
        }
    }
    
    var body: some View {
        ScrollView {
            HStack() {
                Button(action: {
                    nav.dismissModal()
                }, label: {
                    Text("Cancel")
                })
                .padding(.trailing, 10)
                Text("Account creation")
                    .bold()
                    .font(.system(size: 30).bold())
                    .lineLimit(1)
                Spacer()
            }
            .padding(.vertical)
            .padding(.horizontal)
            
            VStack(alignment: .leading) {
                Text("Account info")
                    .font(.system(size: 20).weight(.semibold))
                
                CustomTextField(text: $name, placeholder: "Account Name", style: .text)
                CustomTextField(text: $phoneNumber, placeholder: "Primary Phone", style: .phone)
                CustomTextField(text: $email, placeholder: "Primary Email", style: .email)
            }
            .padding(.horizontal)
            VStack(alignment: .leading) {
                Text("Address info")
                    .font(.system(size: 20).weight(.semibold))
                HStack {
                    CustomTextField(text: $address, placeholder: "Street Address", style: .text)
                        .frame(width: 240)
                    CustomTextField(text: $city, placeholder: "City", style: .text)
                }
                HStack {
                    CustomTextField(text: $state, placeholder: "State", style: .text)
                    CustomTextField(text: $country, placeholder: "Country", style: .text)
                    CustomTextField(text: $zip, placeholder: "ZIP", style: .phone)
                }
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, content: {
                Text("Account notes")
                    .font(.system(size: 20).weight(.semibold))
                TextEditor(text: $accountNotes)
                    .frame(width: 350, height: 150)
                    .border(.secondary)
            })
            Button {
                addAccount()
            } label: {
                Text("Create account")
                    .font(.system(size: 35).weight(.semibold))
            }

        }
    }
}

#Preview {
    CreateAccountView()
}
