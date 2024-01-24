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
        return Self.remoteConfig["iOS.\(rawValue)"].boolValue
    }
    
    func set(_ isEnabled: Bool) {
        #if DEBUG
        Self.defaults.set(isEnabled, forKey: "FeatureFlags.\(rawValue)")
        #endif
    }
    
    static let remoteConfig = RemoteConfig.remoteConfig()
    
    // share the same UserDefaults between `funnelmink` and `funnelmink dev`
    static let defaults = UserDefaults(suiteName: "group.com.funnelmink.crm")!
    
    // TODO: is this correct?
    static func setup() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
    }
    
    // TODO: is this needed?
//    static func fetch() async {
//        do {
//            try await remoteConfig.fetchAndActivate()
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
//
}
