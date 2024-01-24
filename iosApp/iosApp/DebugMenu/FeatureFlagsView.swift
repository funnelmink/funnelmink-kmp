//
//  FeatureFlagsView.swift
//  iosApp
//
//  Created by Jared Warren on 1/18/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import SwiftUI

struct FeatureFlagsView: View {
    @AppStorage("FeatureFlags.isOverridingRemoteConfig", store: FeatureFlags.defaults) var isOverridingRemoteConfig = false
    var hint: String {
        isOverridingRemoteConfig ?
        "Override" :
        "RemoteConfig"
    }
    
    var icon: String {
        isOverridingRemoteConfig ?
        "flag.fill" :
        "flag"
    }
    
    var color: Color {
        isOverridingRemoteConfig ?
        .purple :
        .white
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack {
                Toggle(
                    isOn: $isOverridingRemoteConfig,
                    label: {
                        HStack {
                            Image(systemName: icon)
                                .foregroundStyle(color)
                            Text(hint)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                )
            }
            .padding()
            
            DebugDivider()
            
            ScrollView {
                ForEach(FeatureFlags.allCases, id: \.self) { flag in
                    Toggle(
                        isOn: Binding(
                            get: { flag.isEnabled },
                            set: { newValue in flag.set(newValue) }
                        ),
                        label: { Text(flag.rawValue) }
                    )
                    .fontWeight(flag.isEnabled ? .bold : .thin)
                }
                .disabled(!isOverridingRemoteConfig)
                .padding()
            }
        }
        .foregroundStyle(.white)
    }

    func captionLabel(_ string: String, color: Color = .secondary) -> some View {
        Text(string)
            .foregroundStyle(color)
            .font(.caption)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    FeatureFlagsView()
}
