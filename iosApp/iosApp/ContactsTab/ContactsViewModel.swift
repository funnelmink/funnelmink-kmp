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
            Toast.warn(error)
        }
    }
    
    @MainActor
    func createContact(
        firstName: String,
        lastName: String,
        emails: [String],
        phoneNumbers: [String],
        companyName: String,
        isOrganization: Bool,
        latitude: Double?,
        longitude: Double?,
        street1: String?,
        street2: String?,
        city: String?,
        state: String?,
        country: String?,
        zip: String?,
        onSuccess: @escaping () -> Void
    ) async {
        do {
            let body = CreateContactRequest(
                firstName: firstName,
                lastName: lastName,
                emails: emails,
                phoneNumbers: phoneNumbers,
                companyName: companyName,
                isOrganization: isOrganization,
                latitude: latitude?.kotlinValue,
                longitude: longitude?.kotlinValue,
                street1: street1,
                street2: street2,
                city: city,
                state: state,
                country: country,
                zip: zip
            )
//            if !Utilities.validation.isName(input: body.name) {
//                throw "\(body.name) contains invalid characters"
//            }
//            for number in body.phoneNumbers {
//                if !Utilities.validation.isPhoneNumber(input: number) {
//                    throw "\(number) is not a valid phone number"
//                }
//            }
//            for email in body.emails {
//                if !Utilities.validation.isEmail(input: email) {
//                    throw "\(email) is not a valid email"
//                }
//            }
//            if let jobTitle = body.jobTitle {
//                if !Utilities.validation.isName(input: jobTitle) {
//                    throw "\(jobTitle) contains invalid characters"
//                }
//            }
            _ = try await Networking.api.createContact(body: body)
            onSuccess()
        } catch {
            Toast.warn(error)
        }
    }
    
    @MainActor
    func updateContact() async {
        do {
            let body = UpdateContactRequest(
                firstName: "",           //  String
                lastName: nil,
                emails: [],         //  [String]
                phoneNumbers: [],   //  [String]
                companyName: nil,       //  String?
                isOrganization: false,
                latitude: nil,
                longitude: nil,
                street1: nil,
                street2: nil,
                city: nil,
                state: nil,
                country: nil,
                zip: nil
            )
            
            _ = try await Networking.api.updateContact(id: "", body: body)
        } catch {
            Toast.warn(error)
        }
    }
    
    @MainActor
    func deleteContact(id: String) async {
        do {
            try await Networking.api.deleteContact(id: id)
        } catch {
            Toast.warn(error)
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
