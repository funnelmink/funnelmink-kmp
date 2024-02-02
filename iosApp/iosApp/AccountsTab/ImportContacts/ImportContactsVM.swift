//
//  ImportContactsVM.swift
//  iosApp
//
//  Created by Jared Warren on 10/19/23.
//  Copyright © 2023 FunnelMink. All rights reserved.
//

import Contacts
import UIKit

class ImportContactsVM: ViewModel {
    @Published var state = State()

    struct State: Hashable {
        var contacts: [ImportableContact] = []
        var searchText: String = ""
    }
    
    func onAppear(completion: @escaping (AccessLevel) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let store = CNContactStore()
            let keysToFetch = [
                CNContactGivenNameKey,
                CNContactFamilyNameKey,
                CNContactPhoneNumbersKey
            ] as [CNKeyDescriptor]
            
            let request = CNContactFetchRequest(keysToFetch: keysToFetch)
            var invitable: [ImportableContact] = []
            
            do {
                try store.enumerateContacts(with: request) { contact, _ in
                    for phoneNumber in contact.phoneNumbers where !(contact.givenName + contact.familyName).isEmpty {
                        invitable.append(
                            ImportableContact(
                                name: "\(contact.givenName) \(contact.familyName)",
                                phoneNumber: phoneNumber.value.stringValue
                            )
                        )
                    }
                }
                DispatchQueue.main.async {
                    self.state.contacts = invitable.sorted { $0.name < $1.name }
                    completion(.granted)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.prohibited)
                }
            }
        }
    }
    
    enum AccessLevel {
        case granted
        case prohibited
        case unknown
    }
}
