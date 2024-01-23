//
//  ImportContactsView.swift
//  iosApp
//
//  Created by Jared Warren on 10/19/23.
//  Copyright © 2023 FunnelMink, LLC. All rights reserved.
//

import SwiftUI

struct ImportContactsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var nav: Navigation
    @State private var vm = ImportContactsVM()
    @State private var accessLevel: ImportContactsVM.AccessLevel = .unknown
    private var filteredContacts: [ImportableContact] {
        if vm.searchText.isEmpty {
            return vm.contacts
        } else {
            return vm.contacts.filter { contact in
                contact.name.localizedCaseInsensitiveContains(vm.searchText)
            }
        }
    }
    
    @ViewBuilder
    var body: some View {
        switch accessLevel {
        case .granted:
            VStack {
                TextField("Search Contacts", text: $vm.state.searchText)
                    .padding(.leading, 24)
                    .frame(height: 44)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                List(filteredContacts) { contact in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(contact.name)
                            Text(contact.phoneNumber)
                        }
                        Spacer()
                        Button("Import") { Toast.error("TODO") }
                    }
                }
                .listStyle(.inset)
            }
            .padding()
        case .prohibited:
            VStack {
                Text("Allow access to import your contacts?")
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                HStack {
                    Spacer()
                    Button("Cancel") {
                        nav.dismissModal()
                    }
                    Button("Allow") {
                        nav.externalDeeplink(to: .settings)
                    }
                    Spacer()
                }
            }
            .padding()
            .onAppear {
                vm.onAppear { accessLevel = $0 }
            }
        case .unknown:
            Color
                .clear
                .overlay(ProgressView())
                .onAppear {
                    vm.onAppear { accessLevel = $0 }
                }
        }
    }
}


#Preview {
    ImportContactsView()
}

struct ImportableContact: Identifiable, Hashable {
    var id: String { phoneNumber }
    var name: String
    var phoneNumber: String
}
