//
//  CreateAccountView.swift
//  iosApp
//
//  Created by Jeremy Warren on 1/13/24.
//  Copyright © 2024 orgName. All rights reserved.
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
                try await viewModel.createAccount(
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
                    type: isIndividual ? .individual : .organization,
                    leadID: nil
                )
                nav.dismissModal()
            } catch {
                Toast.error(error)
            }
        }
    }
    
    func formatAsPhoneNumber(_ input: String) -> String {
        // Remove non-numeric characters
        let digits = input.filter { "0123456789".contains($0) }
        
        // Format according to the US phone number pattern
        let maxDigits = 10
        let prefix = String(digits.prefix(maxDigits))
        
        // Apply the formatting
        if prefix.count > 3 && prefix.count <= 6 {
            let index = prefix.index(prefix.startIndex, offsetBy: 3)
            return "(\(prefix.prefix(upTo: index))) \(prefix.suffix(from: index))"
        } else if prefix.count > 6 {
            let areaCodeIndex = prefix.index(prefix.startIndex, offsetBy: 3)
            let exchangeIndex = prefix.index(prefix.startIndex, offsetBy: 6)
            let areaCode = prefix.prefix(upTo: areaCodeIndex)
            let exchange = prefix[areaCodeIndex..<exchangeIndex]
            let subscriber = prefix.suffix(from: exchangeIndex)
            return "(\(areaCode)) \(exchange)-\(subscriber)"
        } else {
            return prefix
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
                    CustomTextField(text: $country, placeholder: "Country", style: .phone)
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
