//
//  JoinExistingWorkspaceViewModel.swift
//  funnelmink
//
//  Created by Jared Warren on 1/1/24.
//  Copyright © 2024 FunnelMink, LLC. All rights reserved.
//

import Foundation

class JoinExistingWorkspaceViewModel: ViewModel {
    @Published var state = State()
    
    struct State: Hashable {
        
    }
    
    @MainActor
    func requestWorkspaceMembership(name: String, onSuccess: @escaping () -> Void) async {
        do {
            try await Networking.api.requestWorkspaceMembership(name: name)
        } catch {
            AppState.shared.error = error
            // TODO: if the error is 404, set AppState.shared.prompt = "Workspace not found"
        }
    }
}
