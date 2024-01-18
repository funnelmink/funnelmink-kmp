//
//  CreateContactView.swift
//  iosApp
//
//  Created by Jeremy Warren on 1/13/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import SwiftUI
import Shared

struct CreateContactView: View {
    @EnvironmentObject var nav: Navigation
    @StateObject var viewModel = ContactsViewModel()
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var businessName: String = ""
    @State var email: String = ""
    @State var address: String = ""
    @State var phoneNumber: String = ""
    @State var emails: [String] = []
    @State var phoneNumbers: [String] = []
    @State var jobTitle: String = ""
    @State var isIndividual: Bool = true
    
    func addContact() {
        Task {
            await viewModel.createContact(
                firstName: firstName,
                lastName: lastName,
                emails: emails,
                phoneNumbers: phoneNumbers,
                companyName: businessName
            )
            nav.dismissModal()
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    nav.dismissModal()
                }, label: {
                    Text("Cancel")
                })
                Spacer()
                Button(action: {
                    addContact()
                }, label: {
                    Text("Done")
                })
            }
            .padding(.horizontal)
            Spacer()
            HStack(spacing: 20) {
                Button(action: {
                    isIndividual = true
                }, label: {
                    VStack {
                        Image(systemName: "person")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
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
                            .frame(width: 24, height: 24)
                        Text("Business")
                    }
                    .foregroundStyle(isIndividual ? .black : .blue)
                })
            }
            VStack {
                HStack {
                    CustomTextField(text: $firstName, placeholder: "First", style: .text)
                    CustomTextField(text: $lastName, placeholder: "Last", style: .text)
                }
                .padding(.horizontal)
                CustomTextField(text: $businessName, placeholder: "Company", style: .text)
                    .padding(.horizontal)
                CustomTextField(text: $email, placeholder: "Email", style: .email)
                    .padding(.horizontal)
                CustomTextField(text: $address, placeholder: "Address", style: .text)
                    .padding(.horizontal)
                CustomTextField(text: $phoneNumber, placeholder: "Phone Number", style: .phone)
                    .padding(.horizontal)
            }
            Spacer()
        }
        .padding(.vertical)
    }
}

#Preview {
    CreateContactView()
}
