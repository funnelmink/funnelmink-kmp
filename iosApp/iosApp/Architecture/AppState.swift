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
    @Published var user: Shared.User?
    @Published var workspace: Workspace?
    @Published var hasInitialized = false

    var isWorkspaceOwner: Bool { workspace?.role == .owner }
    
    @MainActor
    func configure(token: String?) {
        do {
            if let token,
               let uid = UserDefaults.standard.string(forKey: "userID"),
               let user = try Networking.api.getCachedUser(id: uid) {
                signIn(user: user, token: token)
                
                if let workspaceID = UserDefaults.standard.string(forKey: "workspaceID"),
                   let workspace = try Networking.api.getCachedWorkspace(id: workspaceID) {
                    signIntoWorkspace(workspace)
                }
            }
        } catch {
            Logger.logWarning(error)
        }
        hasInitialized = true
    }
    
    func signOut() {
        do {
            try Networking.api.signOut()
            try Auth.auth().signOut()
            user = nil
            workspace = nil
            UserDefaults.standard.removeObject(forKey: "userID")
            UserDefaults.standard.removeObject(forKey: "workspaceID")
        } catch {
            Logger.logWarning(error)
        }
    }
    
    func signIn(user: Shared.User, token: String) {
        self.user = user
        do {
            UserDefaults.standard.set(user.id, forKey: "userID")
            try Networking.api.signIn(user: user, token: token)
#if DEBUG
            Utilities.shared.logger.setIsLoggingEnabled(value: true)
#else
            if Properties.isDevEnvironment {
                Utilities.shared.logger.setIsLoggingEnabled(value: true)
            }
#endif
        } catch {
            Logger.logWarning(error)
            Toast.error("\(error)\n\nPlease uninstall and reinstall the app. Sorry for the inconvenience!")
        }
    }
    
    func signIntoWorkspace(_ workspace: Workspace) {
        do {
            try Networking.api.signOutOfWorkspace()
            UserDefaults.standard.set(workspace.id, forKey: "workspaceID")
            self.workspace = workspace
            try Networking.api.signIntoWorkspace(workspace: workspace)
        } catch {
            Logger.logError(error)
            Toast.error("\(error)\n\nPlease uninstall and reinstall the app. Sorry for the inconvenience!")
        }
    }
}
