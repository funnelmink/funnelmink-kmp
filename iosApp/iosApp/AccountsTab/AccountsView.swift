//
//  AccountsView.swift
//  iosApp
//
//  Created by JEREMY Warren on 10/19/23.
//  Copyright © 2023 FunnelMink. All rights reserved.
//

import SwiftUI
import Shared

enum AccountSelection: String {
    case all
    case contacts
}

struct AccountsView: View {
    @EnvironmentObject var nav: Navigation
    @StateObject var viewModel = AccountsViewModel()
    @AppStorage("accountsView.selection") var selection: AccountSelection = .all
    @State var searchText: String = ""
    @State var allContacts: [AccountContact] = []
    
    
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
        List {
            switch selection {
            case .all: allAccounts
            case .contacts: allAccountContacts
            }
        }
        .searchable(text: $searchText)
        .navigationTitle(selection == .all ? "Accounts" : "Contacts")
        .onChange(of: selection) { newValue in
            if newValue == .contacts {
                fetchAllContacts()
            }
        }
        .toolbar {
            ToolbarItem {
                Picker("Sort Order", selection: $selection) {
                    Text("Accounts").tag(AccountSelection.all)
                    Text("Contacts").tag(AccountSelection.contacts)
                }
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
    
    var allAccountContacts: some View {
        ForEach(allContacts, id: \.id) { contact in
            if let name = contact.name {
                Text(name)
            }
        }
    }
    
    var allAccounts: some View {
        ForEach(sortedGroupKeys, id: \.self) { key in
            Section(header: Text(key)) {
                ForEach(filteredAccounts[key] ?? [], id: \.id) { account in
                    Button(action: {
                        nav.segue(.accountView(account))
                    }, label: {
                        CustomCell(title: account.name, cellType: .navigation)
                            .foregroundStyle(Color.primary)
                    })
                }
                .onDelete { offsets in
                    deleteAccount(at: offsets, from: key)
                }
            }
        }
    }
    
    private func fetchAllContacts() {
        Task {
            do {
                var contacts: [AccountContact] = []
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
