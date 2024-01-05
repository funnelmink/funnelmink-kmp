//
//  ViewModel.swift
//  iosApp
//
//  Created by Jared Warren on 10/19/23.
//  Copyright © 2023 FunnelMink, LLC. All rights reserved.
//

import Combine
import Foundation

@dynamicMemberLookup
protocol ViewModel: ObservableObject where Self.ObjectWillChangePublisher == ObservableObjectPublisher {
    associatedtype State: Hashable
    var state: State { get set }
}

extension ViewModel {
    subscript<Value>(dynamicMember keyPath: KeyPath<State, Value>) -> Value {
        state[keyPath: keyPath]
    }
    
    /// Normally SwiftUI Views are updated  every state change. Using `batch` improves performance by delaying the update until all changes are made.
    func batch(_ update: (inout State) -> Void) {
        var state = state
        update(&state)
        self.state = state
    }
}
