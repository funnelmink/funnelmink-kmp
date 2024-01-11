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
            baseURL: Properties.baseURL
        )
        
        fmapi.onAuthFailure = { _ in
            Task { @MainActor in
                do {
                    Networking.api.token = try await Auth.auth().currentUser?.getIDTokenResult(forcingRefresh: true).token
                } catch {
                    AppState.shared.prompt = "Your session has expired. Please log in again."
                }
            }
        }
        
        // TODO: all of the following will also need to be surfaced to the user
        fmapi.onBadRequest = { message in
            Task { @MainActor in
                AppState.shared.error = message
            }
        }
        
        fmapi.onDecodingError = { message in
            Task { @MainActor in
                AppState.shared.error = message
            }
        }
        
        fmapi.onMissing = { message in
            Task { @MainActor in
                AppState.shared.error = message
            }
        }
        
        fmapi.onServerError = { message in
            Task { @MainActor in
                AppState.shared.error = message
            }
        }
        
        return fmapi
    }()
}

