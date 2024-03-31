//
//  AccountsView.swift
//  iosApp
//
//  Created by JEREMY Warren on 10/19/23.
//  Copyright © 2023 FunnelMink. All rights reserved.
//

import SwiftUI
import Shared

enum AccountSelection: String, CaseIterable {
    case all = "Accounts + Contacts"
    case contacts = "Contacts"
    case accounts = "Accounts"
}

struct AccountsView: View {
    @EnvironmentObject var nav: Navigation
    @StateObject var viewModel = AccountsViewModel()
    @AppStorage("accountsView.selection") var selection: AccountSelection = .all
    @State private var selectedFilter: AccountSelection = .contacts
    @State var searchText: String = ""
    @State var allContacts: [Contact] = []
    
    let backgroundForButton = Color(hex: "F2F2F7")
    
    
    private var filteredAccounts: [String : [Account]] {
        if searchText.isEmpty {
            return groupedAccounts
        } else {
            var results: [String: [Account]] = [:]
            for (key, value) in groupedAccounts {
                results[key] = value.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            }
            return results
        }
    }
    
    private var groupedAccounts: [String: [Account]] {
        Dictionary(grouping: viewModel.accounts, by: { String($0.name.prefix(1)) })
    }
    
    private var sortedGroupKeys: [String] {
        groupedAccounts.keys.sorted()
    }
    
    private func deleteAccount(at offsets: IndexSet, from sectionKey: String) {
        
        guard let accountsInSection = filteredAccounts[sectionKey] else { return }
        
        let accountsToDelete = offsets.map { accountsInSection[$0] }
        guard let id = accountsToDelete.first?.id else { return }
        Task {
            do {
                try await viewModel.deleteAccount(id: id)
            } catch {
                Toast.error(error)
            }
        }
    }
    
    @ViewBuilder
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(AccountSelection.allCases, id: \.self) { newSelection in
                    Button(action: {
                        selection = newSelection
                    }) {
                        Text(newSelection.rawValue)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(selection == newSelection ? Color.teal : backgroundForButton)
                            .foregroundColor(selection == newSelection ? .white : .secondary)
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
        }
        List {
            ForEach(viewModel.state.accounts, id: \.self) { account in
               accountAndContactsRows(account)
            }
            
        }
        .searchable(text: $searchText, prompt: selection == .all ? "Search Accounts" : "Search Contacts")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                // Your custom leading items here, if any.
            }
            ToolbarItemGroup(placement: .principal) {
                NavigationSearchView()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                // Your custom trailing items here, if any.
            }
        }
        
        .navigationTitle(selection == .all ? "Accounts" : "Contacts")
        .onChange(of: selection) { newValue in
            if newValue == .contacts {
                fetchAllContacts()
            }
        }
        .loggedTask {
            do {
                try await viewModel.getAccounts()
            } catch {
                Toast.error(error)
            }
        }
    }
    
    @ViewBuilder
    func accountAndContactsRows(_ account: Account) -> some View {
        if [AccountSelection.all, .accounts].contains(selection) {
            Button {
                nav.segue(.accountDetailsView(account))
            } label: {
                CustomCell(title: account.name, icon: "building.2", cellType: .navigation)
            }
        }
        
        ForEach(account.contacts, id: \.self) { contact in
            if [AccountSelection.all, .contacts].contains(selection) {
                Button {
                    nav.segue(.contactDetailsView(contact))
                } label: {
                    CustomCell(title: contact.name, icon: "person.fill", cellType: .navigation)
                }
            }
        }
    }
    
    private func fetchAllContacts() {
        Task {
            do {
                var contacts: [Contact] = []
                for account in viewModel.accounts {
                    let details = try await Networking.api.getAccountDetails(id: account.id)
                    contacts.append(contentsOf: details.contacts)
                }
                self.allContacts = contacts
            } catch {
                Toast.error("Unable to get account details")
            }
        }
    }
}

#Preview {
    AccountsView(selection: .all)
}
