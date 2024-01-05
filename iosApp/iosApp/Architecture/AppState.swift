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
    
    // TODO: on dev builds, present alert. on prod builds, log the error to Google Analytics instead
    /// only displays an alert to devs
    @Published var error: Error?
    
    /// displays an alert to the user
    @Published var prompt: String?
    
    var isWorkspaceOwner: Bool { workspace?.role == .owner }
    
    @MainActor
    func configure() {
        Task {
            if let user = Auth.auth().currentUser {
                await signIn(user)
            }
            if let data = UserDefaults.standard.object(forKey: "appState") as? Data,
               let persistentAppState = try? JSONDecoder().decode(PersistentAppState.self, from: data) {
                let workspace = Workspace(
                    id: persistentAppState.workspaceID,
                    name: persistentAppState.workspaceName,
                    role: persistentAppState.role,
                    avatarURL: nil
                )
                self.workspace = workspace
                Networking.api.workspaceID = workspace.id
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
    func signIn(_ user: FirebaseAuth.User) async {
        self.user = user
        do {
            Networking.api.token = try await user.getIDToken()
        } catch {
            self.error = error
        }
    }
    
    func signIntoWorkspace(_ workspace: Workspace) {
        Networking.api.workspaceID = workspace.id
        self.workspace = workspace
        let persistentAppState = PersistentAppState(workspaceID: workspace.id, workspaceName: workspace.name, workspaceRoleName: workspace.role?.name)
        if let data = try? JSONEncoder().encode(persistentAppState) {
            UserDefaults.standard.setValue(data, forKey: "appState")
        }
    }
    
    func todo() {
        error = "TODO"
    }
}

fileprivate struct PersistentAppState: Codable {
    let workspaceID: String
    let workspaceName: String
    let workspaceRoleName: String?
    
    var role: WorkspaceMembershipRole? {
        switch workspaceRoleName {
        case "OWNER": return .owner
        case "MEMBER": return .member
        case "INVITED": return .invited
        case "REQUESTED": return .requested
        default: return nil
        }
    }
}
