//
//  WorkspaceSettingsViewModel.swift
//  funnelmink
//
//  Created by Jared Warren on 12/29/23.
//  Copyright © 2023 FunnelMink, LLC. All rights reserved.
//

import Combine
import Foundation
import Shared

class WorkspaceSettingsViewModel: ViewModel {
    @Published var state = State()
    private var subscriptions = Set<AnyCancellable>()
    
    struct State: Hashable {
        var workspaceMembers: [WorkspaceMember] = []
    }
    
    @MainActor
    func onAppear() async {
        await fetchWorkspaceMembers()
        
        // if they change workspaces, update the UI
        AppState
            .shared
            .$workspace
            .sink { [weak self] _ in
                Task {
                    await self?.fetchWorkspaceMembers()
                }
            }
            .store(in: &subscriptions)

    }
    
    @MainActor
    private func fetchWorkspaceMembers() async {
        do {
            state.workspaceMembers = try await Networking.api.getWorkspaceMembers()
        } catch {
            Toast.error(error)
        }
    }
    
    @MainActor
    func leaveWorkspace() async {
        if AppState.shared.role == .admin {
            let admins = state.workspaceMembers.filter { $0.role == .admin }
            guard admins.count > 1 else {
                Toast.warn("You can't leave the workspace because you are the only Admin.\nPlease promote another member before leaving.")
                return
            }
        }
        
        do {
            try await Networking.api.leaveWorkspace()
            AppState.shared.workspace = nil
            state.workspaceMembers = []
        } catch {
            Toast.error(error)
        }
    }
    
    @MainActor
    func removeMemberFromWorkspace(id: String) async {
        guard AppState.shared.role == .admin else {
            Toast.warn("You must be an Admin to remove members.")
            return
        }
        guard id != AppState.shared.user?.id else {
            Toast.warn("You can't remove yourself.")
            return
        }
        do {
            try await Networking.api.removeMemberFromWorkspace(userID: id)
            state.workspaceMembers.removeAll(where: { $0.userID == id })
        } catch {
            Toast.error(error)
        }
    }
    
    @MainActor
    func changeMemberRole(id: String, to role: WorkspaceMembershipRole) {
        Task {
            do {
                try await Networking.api.changeWorkspaceRole(userID: id, role: role)
                if let index = state.workspaceMembers.firstIndex(where: { $0.userID == id }) {
                    state.workspaceMembers[index].role = role
                }
            } catch {
                Toast.error(error)
            }
        }
    }
    
    @MainActor
    func acceptWorkspaceRequest(userID: String, role: WorkspaceMembershipRole) async {
        do {
            try await Networking.api.acceptWorkspaceRequest(userID: userID, role: role)
            if let index = state.workspaceMembers.firstIndex(where: { $0.userID == userID }) {
                state.workspaceMembers[index].role = role
            }
        } catch {
            Toast.error(error)
        }
    }
    
    @MainActor
    func declineWorkspaceRequest(userID: String) async {
        do {
            try await Networking.api.declineWorkspaceRequest(userID: userID)
            if let index = state.workspaceMembers.firstIndex(where: { $0.userID == userID }) {
                state.workspaceMembers.remove(at: index)
            }
        } catch {
            Toast.error(error)
        }
    }
    
    @MainActor
    func deleteWorkspace() async {
        do {
            _ = try await Networking.api.deleteWorkspace()
            AppState.shared.workspace = nil
            state.workspaceMembers = []
        } catch {
            Toast.error(error)
        }
    }
    
    @MainActor
    func updateWorkspace(name: String) async {
        guard name != AppState.shared.workspace?.name else { return }
        if name.isEmpty {
            Toast.warn("Name cannot be empty.")
            return
        }
        if !Validator.isValidName(name) {
            Toast.warn("`\(name)` is not a valid name")
            return
        }
        
        do {
            let body = UpdateWorkspaceRequest(name: name, avatarURL: nil)
            let workspace = try await Networking.api.updateWorkspace(body: body)
            AppState.shared.workspace = workspace
        } catch {
            Toast.error(error)
        }
    }
}
