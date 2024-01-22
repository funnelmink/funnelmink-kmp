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
            Toast.warn(error)
        }
    }
}
