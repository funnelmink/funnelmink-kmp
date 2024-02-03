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
    @State var businessName: String = "" // This is going away (the account is the company)
    @State var email: String = ""
    @State var address: String = ""
    @State var phoneNumber: String = ""
    @State var emails: [String] = []
    @State var phoneNumbers: [String] = []
    @State var jobTitle: String = ""
    @State var isIndividual: Bool = true
    
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
                    city: nil,
                    state: nil,
                    country: nil,
                    zip: nil,
                    notes: nil,
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
            HStack {
                Button(action: {
                    nav.dismissModal()
                }, label: {
                    Text("Cancel")
                })
                Spacer()
                Button(action: {
                    addAccount()
                }, label: {
                    Text("Done")
                })
            }
            .padding(.horizontal)
            Spacer()
            HStack(spacing: 35) {
                Button(action: {
                    isIndividual = true
                }, label: {
                    VStack {
                        Image(systemName: "person")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 125, height: 125)
                        Text("Individual")
                    }
                    
                    .foregroundStyle(isIndividual ? .blue : .black)
                })
                Button(action: {
                    isIndividual = false
                }, label: {
                    VStack {
                        Image(systemName: "building")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 125, height: 125)
                        Text("Business")
                    }
                    .foregroundStyle(isIndividual ? .black : .blue)
                })
            }
            VStack {
                HStack {
                    CustomTextField(text: $name, placeholder: "Name", style: .text)
                        .autocorrectionDisabled()
                }
                .padding(.horizontal)
                CustomTextField(text: $businessName, placeholder: "Company", style: .text)
                    .padding(.horizontal)
                    .autocorrectionDisabled()
                CustomTextField(text: $email, placeholder: "Email", style: .email)
                    .padding(.horizontal)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                CustomTextField(text: $address, placeholder: "Address", style: .text)
                    .padding(.horizontal)
                    .autocorrectionDisabled()
                CustomTextField(text: $phoneNumber, placeholder: "Phone Number", style: .phone)
                    .padding(.horizontal)
                    .onChange(of: phoneNumber) { newValue in
                        phoneNumber = formatAsPhoneNumber(newValue)
                    }
            }
            Spacer()
        }
        .padding(.vertical)
    }
}

#Preview {
    CreateAccountView()
}
