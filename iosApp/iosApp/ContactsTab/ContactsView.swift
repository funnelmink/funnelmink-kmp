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
    
    private var filteredContacts: [String : [Contact]] {
        if searchText.isEmpty {
            return groupedContacts
        } else {
            var results: [String: [Contact]] = [:]
            for (key, value) in groupedContacts {
                results[key] = value.filter { ($0.firstName + ($0.lastName ?? "")).lowercased().contains(searchText.lowercased()) }
            }
            return results
        }
    }
    
    private var groupedContacts: [String: [Contact]] {
        Dictionary(grouping: viewModel.contacts, by: { String($0.firstName.prefix(1)) })
    }
    
    private var sortedGroupKeys: [String] {
        groupedContacts.keys.sorted()
    }
    
    private func deleteContact(at offsets: IndexSet, from sectionKey: String) {
        
        guard let contactsInSection = filteredContacts[sectionKey] else { return }
        
        let contactsToDelete = offsets.map { contactsInSection[$0] }
        guard let id = contactsToDelete.first?.id else { return }
        Task {
            await viewModel.deleteContact(id: id)
        }
    }
    
    @ViewBuilder
    var body: some View {
        Group {
            if !viewModel.contacts.isEmpty {
                List {
                    ForEach(sortedGroupKeys, id: \.self) { key in
                        Section(header: Text(key)) {
                            ForEach(filteredContacts[key] ?? [], id: \.id) { contact in
                                Button(action: {
                                    nav.performSegue(.contactView(contact))
                                }, label: {
                                    CustomCell(title: contact.firstName + " " + (contact.lastName ?? ""), cellType: .navigation)
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
            } else {
                CustomEmptyView(type: .contacts, lottieAnimation: "ContactsLottie")
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    nav.modalSheet(.createContact) {
                        Task {
                            await viewModel.getContacts()
                        }
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationTitle("Contacts")
        .loggedTask {
            await viewModel.getContacts()
        }
    }
}

#Preview {
    ContactsView()
}
