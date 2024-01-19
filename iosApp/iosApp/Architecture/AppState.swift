//
//  AppState.swift
//  funnelmink
//
//  Created by Jared Warren on 11/25/23.
//  Copyright © 2023 FunnelMink, LLC. All rights reserved.
//

import Foundation
import FirebaseAuth
import Shared

final class AppState: ObservableObject {
    static let shared = AppState()
    @Published var user: FirebaseAuth.User?
    @Published var workspace: Workspace?
    @Published var hasInitialized = false
    
    // TODO: replace this nonsense with Logging and Toasts. Toast automatically logs to console (toast: )
    /// only displays an alert to devs
    @Published var error: Error?
    
    /// displays an alert to the user
    @Published var prompt: String?
    
    var isWorkspaceOwner: Bool { workspace?.role == .owner }
    
    @MainActor
    func configure() {
        Task {
            if let firebaseUser = Auth.auth().currentUser,
               let funnelminkUser = try? await Networking.api.getCachedUser(id: firebaseUser.uid) {
                await signIn(firebaseUser: firebaseUser, funnelminkUser: funnelminkUser)
                
                if let workspaceID = UserDefaults.standard.string(forKey: "workspaceID"),
                   let workspace = Networking.api.getCachedWorkspace(id: workspaceID) {
                    signIntoWorkspace(workspace)
                }
            }
            hasInitialized = true
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            user = nil
            workspace = nil
            UserDefaults.standard.removeObject(forKey: "appState")
        } catch {
            self.error = error
        }
    }
    
    @MainActor
    func signIn(firebaseUser: FirebaseAuth.User, funnelminkUser: Shared.User) async {
        self.user = user
        do {
            let token = try await firebaseUser.getIDToken()
            Networking.api.signIn(user: funnelminkUser, token: token)
#if DEBUG
            Utilities.shared.logger.setIsLoggingEnabled(value: true)
#endif
        } catch {
            self.error = error
        }
    }
    
    func signIntoWorkspace(_ workspace: Workspace) {
        self.workspace = workspace
        Networking.api.signIntoWorkspace(workspace: workspace)
    }
    
    func todo() {
        error = "TODO"
    }
}
