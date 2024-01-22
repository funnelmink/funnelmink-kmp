import Foundation
import Shared

class WorkspacesViewModel: ViewModel {
    @Published var state = State()

    struct State: Hashable {
        var didError = false
        var workspaces: [Workspace] = []
    }

    @MainActor
    func fetchWorkspaces() async {
        do {
            state.didError = false
            state.workspaces = try await Networking.api.getWorkspaces()
        } catch {
            state.didError = true
            Toast.warn(error)
        }
    }

    @MainActor
    func createWorkspace(name: String, onSuccess: () -> Void) async {
        do {
            if name.isEmpty {
                Toast.warn("Workspace name cannot be empty.")
                return
            }
            if !Validator.isValidName(name) {
                Toast.warn("\(name) contains invalid characters.")
                return
            }
            let body = CreateWorkspaceRequest(name: name)
            let workspace = try await Networking.api.createWorkspace(body: body)
            state.workspaces.append(workspace)
            AppState.shared.signIntoWorkspace(workspace)
            onSuccess()
        } catch {
            Toast.warn(error)
        }
    }
    
    @MainActor
    func inviteToWorkspace(email: String, onSuccess: @escaping () -> Void) async {
        do {
            try await Networking.api.inviteUserToWorkspace(email: email)
            onSuccess()
        } catch {
            Toast.warn(error)
        }
    }
    
    @MainActor
    func acceptInvite(_ id: String, onSuccess: @escaping () -> Void) async {
        do {
            let workspace = try await Networking.api.acceptWorkspaceInvitation(id: id)
            AppState.shared.signIntoWorkspace(workspace)
            // replace the workspace in the list with the new one
            state.workspaces.removeAll { $0.id == workspace.id }
            state.workspaces.append(workspace)
            onSuccess()
        } catch {
            Toast.warn(error)
        }
    }
    
    @MainActor
    func rejectInvite(_ id: String, onSuccess: @escaping () -> Void) async {
        do {
            try await Networking.api.declineWorkspaceInvitation(id: id)
            state.workspaces.removeAll { $0.id == id }
            onSuccess()
        } catch {
            Toast.warn(error)
        }
    }
}
