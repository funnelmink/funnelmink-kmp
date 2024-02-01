//
//  SwiftUI+.swift
//  iosApp
//
//  Created by Jared Warren on 10/14/23.
//  Copyright © 2023 FunnelMink, LLC. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    func withPreviewDependencies() -> some View {
        self
            .environmentObject(AppState.shared)
            .environmentObject(Navigation.shared)
    }
}
