//
//  ContactsViewModel.swift
//  funnelmink
//
//  Created by Jared Warren on 1/3/24.
//  Copyright © 2024 FunnelMink, LLC. All rights reserved.
//

import Foundation
import Shared

class ContactsViewModel: ViewModel {
    @Published var state = State()
    
    struct State: Hashable {
        var contacts: [Contact] = []
    }
    
    @MainActor
    func getContacts() async {
        do {
            state.contacts = try await Networking.api.getContacts()
        } catch {
            AppState.shared.error = error
        }
    }
    
    @MainActor
    func createContact(name: String, emails: [String], phoneNumbers: [String], jobTitle: String) async {
        do {
            let body = CreateContactRequest(
                name: name,
                emails: emails,
                phoneNumbers: phoneNumbers,
                jobTitle: jobTitle
            )
            
            _ = try await Networking.api.createContact(body: body)
        } catch {
            AppState.shared.error = error
        }
    }
    
    @MainActor
    func updateContact() async {
        do {
            let body = UpdateContactRequest(
                name: "",           //  String
                emails: [],         //  [String]
                phoneNumbers: [],   //  [String]
                jobTitle: nil       //  String?
            )
            
            _ = try await Networking.api.updateContact(id: "", body: body)
        } catch {
            AppState.shared.error = error
        }
    }
    
    @MainActor
    func deleteContact(id: String) async {
        do {
            try await Networking.api.deleteContact(id: id)
        } catch {
            AppState.shared.error = error
        }
    }
    
    // TODO: if the user imports their Apple contacts, upload them to our backend as JSON or CSV
    // func importAppleContacts() async { ... }
    
    
    // TODO: Later, when we add history, locations, etc we'll fetch extra info for the detail view
    //    @MainActor
    //    func getContactDetails(id: String) async {
    //        do {
    //            try await Networking.api.getContactDetails(id: id)
    //        } catch {
    //            AppState.shared.error = error
    //        }
    //    }
}
