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
            
            AppState.shared.configure(token: token)
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

extension AppDelegate {
    private func setUpRemoteConfig() async throws {
        let rc = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        rc.configSettings = settings
        
        _ = try await rc.fetchAndActivate()
    }
}
