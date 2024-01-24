//
//  FeatureFlags.swift
//  iosApp
//
//  Created by Jared Warren on 1/23/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation
import FirebaseRemoteConfig

enum FeatureFlags: String, CaseIterable {
    case funnelsTestUI
    
    static var isOverridingRemoteConfig: Bool {
        #if DEBUG
        defaults.bool(forKey: "FeatureFlags.isOverridingRemoteConfig")
        #else
        false
        #endif
    }
    
    var isEnabled: Bool {
        #if DEBUG
        if Self.isOverridingRemoteConfig {
            return Self.defaults.bool(forKey: "FeatureFlags.\(rawValue)")
        }
        #endif
        return Self.remoteConfig["iOS_\(rawValue)"].boolValue
    }
    
    func set(_ isEnabled: Bool) {
        #if DEBUG
        Self.defaults.set(isEnabled, forKey: "FeatureFlags.\(rawValue)")
        #endif
    }
    
    static private let remoteConfig = RemoteConfig.remoteConfig()
    
    // share the same UserDefaults between `funnelmink` and `funnelmink dev`
    static let defaults = UserDefaults(suiteName: "group.com.funnelmink.crm")!
}
