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
            AppState.shared.error = error
        }
    }
    
    @MainActor
    func leaveWorkspace() async {
        if AppState.shared.isWorkspaceOwner {
            let owners = state.workspaceMembers.filter { $0.role == .owner }
            guard owners.count > 1 else {
                AppState.shared.prompt = "You can't leave the workspace because you are the only owner. Please promote another member to owner before leaving."
                return
            }
        }
        
        do {
            try await Networking.api.leaveWorkspace()
            AppState.shared.workspace = nil
            state.workspaceMembers = []
        } catch {
            AppState.shared.error = error
        }
    }
    
    @MainActor
    func removeMemberFromWorkspace(id: String) async {
        // TODO: also guard that the user is an owner
        guard id != AppState.shared.user?.uid else {
            AppState.shared.error = "You can't remove yourself."
            return
        }
        do {
            try await Networking.api.removeMemberFromWorkspace(userID: id)
            state.workspaceMembers.removeAll(where: { $0.userID == id })
        } catch {
            AppState.shared.error = error
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
                AppState.shared.error = error
            }
        }
    }
    
    @MainActor
    func acceptWorkspaceRequest(userID: String) async {
        do {
            try await Networking.api.acceptWorkspaceRequest(userID: userID)
            if let index = state.workspaceMembers.firstIndex(where: { $0.userID == userID }) {
                state.workspaceMembers[index].role = .member
            }
        } catch {
            AppState.shared.error = error
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
            AppState.shared.error = error
        }
    }
}
