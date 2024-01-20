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
        #endif
//        setupInjectionForDebugBuilds()
        FirebaseApp.configure()
        Task {
            AppState.shared.configure(token: try await Auth.auth().currentUser?.getIDToken())
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
