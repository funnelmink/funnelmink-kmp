//
//  FunnelminkGradient.swift
//  funnelmink
//
//  Created by Jared Warren on 11/28/23.
//  Copyright © 2023 FunnelMink, LLC. All rights reserved.
//

import SwiftUI

struct FunnelminkGradient: View {
    var body: some View {
        LinearGradient(
            gradient: .funnelmink,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

#Preview {
    FunnelminkGradient()
}
