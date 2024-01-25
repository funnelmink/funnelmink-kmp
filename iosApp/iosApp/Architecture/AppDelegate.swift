//
//  AppDelegate.swift
//  funnelmink
//
//  Created by Jared Warren on 11/28/23.
//  Copyright © 2023 FunnelMink, LLC. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseRemoteConfig
import GoogleSignIn
import Shared
import SwiftUI

final class AppDelegate: NSObject, UIApplicationDelegate {
    private lazy var rc = RemoteConfig.remoteConfig()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        #if DEBUG
        print("🪲 DEBUG BUILD 🪲")
        Utilities.shared.logger.setIsLoggingEnabled(value: true)
        #else
        print("🌟 RELEASE BUILD 🌟")
        if Properties.isDevEnvironment {
            Utilities.shared.logger.setIsLoggingEnabled(value: true)
        }
        #endif
        FirebaseApp.configure()
        Task {
            // fire all async requests at the same time
            async let tokenRequest = Auth.auth().currentUser?.getIDToken()
            async let remoteConfig: Void = setUpRemoteConfig()
            
            // pause until all async requests have finished
            let (token, _) = try await (tokenRequest, remoteConfig)
            
            AppState
                .shared
                .configure(
                    token: token,
                    updateWall: shouldDisplayUpdateWall(),
                    whatsNew: shouldDisplayWhatsNew()
                )
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        UserDefaults.standard.setValue(Navigation.shared._state._selectedTab.rawValue, forKey: "Navigation._state._selectedTab")
    }
}

extension AppDelegate {
    private func setUpRemoteConfig() async throws {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        rc.configSettings = settings
        
        _ = try await rc.fetchAndActivate()
    }
    
    private func shouldDisplayUpdateWall() -> Bool {
        guard let minRequired = rc["iOS_updateWall_minVersionRequired"].stringValue,
              let minSuggested = rc["iOS_updateWall_minVersionSuggested"].stringValue,
              !minRequired.isEmpty
        else { return false }
        
        let currentVersion = Properties.appVersion
        
        if currentVersion.compare(minRequired, options: .numeric) == .orderedAscending {
            return true
        } else if currentVersion.compare(minSuggested, options: .numeric) == .orderedAscending {
            return true
        }
        return false
    }
    
    private func shouldDisplayWhatsNew() -> Bool {
        let whatsNewVersion = rc["iOS_whatsNew_version"].numberValue.intValue
        let viewedVersion = UserDefaults.standard.integer(forKey: "iOS_whatsNew_version")
        return whatsNewVersion > viewedVersion
    }
}
