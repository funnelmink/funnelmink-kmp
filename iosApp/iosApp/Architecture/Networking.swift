//
//  Networking.swift
//  funnelmink
//
//  Created by Jared Warren on 11/27/23.
//  Copyright © 2023 FunnelMink, LLC. All rights reserved.
//

import FirebaseAuth
import Foundation
import Shared

class Networking {
    static let api: API = {
        let fmapi = FunnelminkAPI(
            baseURL: Properties.baseURL,
            databaseDriver: DatabaseDriver(),
            cacheThreshold: 60 * 5 // 5 minutes
        )
        
        fmapi.onAuthFailure = { _ in
            Task { @MainActor in
                do {
                    guard let token = try await Auth.auth().currentUser?.getIDTokenResult(forcingRefresh: true).token else {
                        Toast.error("Your session has expired. Please log in again.")
                        return
                    }
                    try Networking.api.refreshToken(token: token)
                } catch {
                    Toast.error("Your session has expired. Please log in again.")
                }
            }
        }
        
        // TODO: all of the following will also need to be surfaced to the user
        fmapi.onBadRequest = { message in
            Task { @MainActor in
                Toast.error(message)
            }
        }
        
        fmapi.onDecodingError = { message in
            Task { @MainActor in
                Toast.error(message)
            }
        }
        
        fmapi.onMissing = { message in
            Task { @MainActor in
                Toast.error(message)
            }
        }
        
        fmapi.onServerError = { message in
            Task { @MainActor in
                Toast.error(message)
            }
        }
        
        return fmapi
    }()
}

