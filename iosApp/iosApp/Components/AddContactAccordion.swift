//
//  AddContactAccordion.swift
//  iosApp
//
//  Created by Jeremy Warren on 2/7/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import SwiftUI

struct AddContactAccordion: View {
    
    func addExpandedContactCard() {
        
    }
    
    var body: some View {
        VStack {
            Button(action: {
                addExpandedContactCard()
            }, label: {
                HStack {
                    Text("Contacts")
                    Spacer()
                    Image(systemName: "plus")
                }
                .foregroundStyle(.black)
            })
        }
        .padding(.horizontal)
    }
}

struct ContactCard: View {
    @State var isExpanded: Bool = false
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var notes: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Contact Info")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                Button {
                    isExpanded.toggle()
                } label: {
                    Image(systemName: isExpanded ? "chevron.down": "chevron.right")
                        .foregroundStyle(.black)
                }

            }
            .padding(.horizontal)
            Divider()
                .foregroundStyle(.black)
                .padding(.horizontal)
            if isExpanded {
                VStack {
                    TextField("Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Phone", text: $phone)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Notes")
                        .font(.headline)
                    
                    TextEditor(text: $notes)
                        .frame(width: 350, height: 150)
                        .border(Color.gray, width: 1)
                    
                }
                    .padding(.horizontal)
                    .padding(.vertical)
            }
        }
    }
}

#Preview {
    ContactCard(isExpanded: true)
}
