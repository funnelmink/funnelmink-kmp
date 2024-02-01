//
//  AccountsView.swift
//  iosApp
//
//  Created by JEREMY Warren on 10/19/23.
//  Copyright © 2023 FunnelMink. All rights reserved.
//

import SwiftUI
import Shared

struct AccountsView: View {
    @EnvironmentObject var nav: Navigation
    @StateObject var viewModel = AccountsViewModel()
    @State var searchText: String = ""
    
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
    
    var body: some View {
        List {
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
        .searchable(text: $searchText)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    nav.modalSheet(.createAccount) {
                        Task {
                            try? await viewModel.getAccounts()
                        }
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationTitle("Accounts")
        .loggedTask {
            do {
                try await viewModel.getAccounts()
            } catch {
                Toast.error(error)
            }
        }
    }
}

#Preview {
    AccountsView()
}
