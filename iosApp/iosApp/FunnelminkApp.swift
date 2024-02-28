import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import Shared
import SwiftUI

@main
struct FunnelminkApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            FunnelminkAppContents()
        }
    }
}

fileprivate struct FunnelminkAppContents: View {
    @StateObject var navigation = Navigation.shared
    @StateObject var appState = AppState.shared
    var body: some View {
        Group {
            if !appState.hasInitialized {
                // Loading screen
                Color.white.overlay { Image("logo") }
            } else if appState.shouldPresentUpdateWall {
                UpdateWallView()
            } else if appState.shouldPresentWhatsNew {
                WhatsNewView()
            } else if appState.user != nil {
                // Logged in and has joined a Workspace
                if let workspace = appState.workspace {
                    TabView(selection: $navigation._state._selectedTab) {
                        ForEach(FunnelminkTab.activeTabConfiguration.indices, id: \.self) { i in
                            let tab = FunnelminkTab.activeTabConfiguration[i]
                            NavigationStack(path: navigation._path(index: i)) {
                                tab.root.navigationDestination(for: Segue.self) { $0.view }
                            }
                            .tabItem { tab.tabItem }
                            .tag(i)
                        }
                    }
                    .tag(workspace.id)

                    // Logged in but no Workspaces
                } else {
                    WorkspacesView() // TODO: pass in whether or not the user has the option to log out
                }
                // Not logged in
            } else {
                NavigationStack(path: $navigation._state._unauthenticated) {
                    LoginView()
                        .navigationDestination(for: UnauthenticatedSegue.self) {
                            $0.view
                        }
                }
            }
        }
        .overlay {
            // TODO: hide this conditionally (.hidden)
            VStack {
                HStack(spacing: 0) {
                    Button {
                        navigation.modalFullscreen(.debugMenu)
                    } label: {
                        Image(systemName: "apple.terminal.fill")
                            .renderingMode(.original)
                            .font(.largeTitle)
                    }
                    .padding(.leading, 64)
                    .padding(.top, 8)
                    if FeatureFlags.isOverridingRemoteConfig {
                        Image(systemName: "flag.fill")
                            .foregroundColor(.purple)
                            .font(.caption)
                    }
                    Spacer()
                }
                Spacer()
            }
        }
        .tint(.accentColor)
        .sheet(
            item: $navigation._state._sheet,
            onDismiss: navigation._onModalDismiss,
            content: { $0.view }
        )
        .fullScreenCover(
            item: $navigation._state._fullscreen,
            onDismiss: navigation._onModalDismiss,
            content: { $0.view }
        )
        .environmentObject(navigation)
        .environmentObject(appState)
        .toasted()
    }
}
