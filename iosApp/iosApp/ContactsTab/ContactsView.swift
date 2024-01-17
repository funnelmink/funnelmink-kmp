//
//  ContactsView.swift
//  iosApp
//
//  Created by JEREMY Warren on 10/19/23.
//  Copyright © 2023 FunnelMink. All rights reserved.
//

import SwiftUI
import Shared

struct ContactsView: View {
    @EnvironmentObject var nav: Navigation
    @StateObject var viewModel = ContactsViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.contacts, id: \.id) { contact in
                Button(action: {
                    nav.performSegue(.contactView(contact))
                }, label: {
                    CustomCell(title: contact.name, cellType: .navigation)
                        .foregroundStyle(Color.primary)
                })
            }
        }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        nav.presentSheet(.createContact)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationTitle("Contacts")
            .task {
                await viewModel.getContacts()
            }
    }
}

#Preview {
    ContactsView()
}
