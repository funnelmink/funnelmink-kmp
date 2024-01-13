//
//  ContactsView.swift
//  iosApp
//
//  Created by JEREMY Warren on 10/19/23.
//  Copyright © 2023 FunnelMink. All rights reserved.
//

import SwiftUI

struct ContactsView: View {
    @EnvironmentObject var nav: Navigation
    @StateObject var viewModel = ContactsViewModel()
    
    var body: some View {
        List {
            Text("Contacts")
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
//                await viewModel.getContacts()
            }
    }
}

#Preview {
    ContactsView()
}
