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
    @State var searchText: String = ""
    
    private var filteredContacts: [Contact] {
        if searchText.isEmpty {
            return viewModel.contacts
        } else {
            return viewModel.contacts.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    private var groupedContacts: [String: [Contact]] {
        Dictionary(grouping: viewModel.contacts, by: { String($0.name.prefix(1)) })
    }
    
    private var sortedGroupKeys: [String] {
        groupedContacts.keys.sorted()
    }
    
    private func deleteContact(at offsets: IndexSet, from sectionKey: String) {
        
        guard let contactsInSection = groupedContacts[sectionKey] else { return }
        
        let contactsToDelete = offsets.map { contactsInSection[$0] }
        guard let id = contactsToDelete.first?.id else { return }
        Task {
            await viewModel.deleteContact(id: id)
        }
    }
    
    var body: some View {
        List {
            ForEach(sortedGroupKeys, id: \.self) { key in
                Section(header: Text(key)) {
                    ForEach(groupedContacts[key] ?? [], id: \.id) { contact in
                        Button(action: {
                            nav.performSegue(.contactView(contact))
                        }, label: {
                            CustomCell(title: contact.name, cellType: .navigation)
                                .foregroundStyle(Color.primary)
                        })
                    }
                    .onDelete { offsets in
                        deleteContact(at: offsets, from: key)
                    }
                }
            }
        }
        .searchable(text: $searchText)
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
