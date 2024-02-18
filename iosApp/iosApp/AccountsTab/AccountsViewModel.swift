//
//  ContactsViewModel.swift
//  funnelmink
//
//  Created by Jared Warren on 1/3/24.
//  Copyright © 2024 FunnelMink, LLC. All rights reserved.
//

import Foundation
import Shared

class AccountsViewModel: ViewModel {
    @Published var state = State()
    
    struct State: Hashable {
        var accounts: [Account] = []
    }
    
    @MainActor
    func getAccounts() async throws {
        state.accounts = try await Networking.api.getAccounts()
    }
    
    @MainActor
    func createAccount(
        name: String,
        email: String?,
        phone: String?,
        latitude: Double?,
        longitude: Double?,
        address: String?,
        city: String?,
        state: String?,
        country: String?,
        zip: String?,
        notes: String?,
        leadID: String?
    ) async throws -> Account {
        let body = CreateAccountRequest(
            name: name,
            email: email,
            phone: phone,
            latitude: latitude?.kotlinValue,
            longitude: longitude?.kotlinValue,
            address: address,
            city: city,
            state: state,
            country: country,
            zip: zip,
            notes: notes,
            leadID: leadID
        )
        let createdAccount = try await Networking.api.createAccount(body: body)
        return createdAccount
    }
    
    @MainActor
    func updateAccount(
        id: String,
        name: String,
        email: String?,
        phone: String?,
        latitude: Double?,
        longitude: Double?,
        address: String?,
        city: String?,
        state: String?,
        country: String?,
        zip: String?,
        notes: String?,
        leadID: String?
    ) async throws {
        let body = UpdateAccountRequest(
            name: name,
            email: email,
            phone: phone,
            latitude: latitude?.kotlinValue,
            longitude: longitude?.kotlinValue,
            address: address,
            city: city,
            state: state,
            country: country,
            zip: zip,
            notes: notes
        )
        _ = try await Networking.api.updateAccount(id: id, body: body)
    }
    
    @MainActor
    func deleteAccount(id: String) async throws {
        try await Networking.api.deleteAccount(id: id)
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
