import FirebaseAuth
import FirebaseCore
import GoogleSignIn
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
            } else if appState.user != nil {
                // Logged in and has joined a Workspace
                if let workspace = appState.workspace {
                    TabView(selection: $navigation._selectedTab) {
                        ForEach(FunnelMinkTab.allCases) { tab in
                            NavigationStack(path: navigation._path(for: tab)) {
                                tab.root.navigationDestination(for: Segue.self) { $0.view }
                            }
                            .tabItem { tab.tabItem }
                            .tag(tab)
                        }

                    }
                    .tag(workspace.id)

                    // Logged in but no Workspaces
                } else {
                    WorkspacesView()
                }

                // Not logged in
            } else {
                NavigationStack(path: $navigation._unauthenticated) {
                    LoginView()
                        .navigationDestination(for: UnauthenticatedSegue.self) {
                            $0.view
                        }
                }
            }
        }
        .overlay {
            VStack {
                HStack {
                    Button {
                        navigation.presentFullscreen(.debugMenu)
                    } label: {
                        Image(systemName: "apple.terminal.fill")
                            .renderingMode(.original)
                    }
                    .padding(.leading, 64)
                    Spacer()
                }
                Spacer()
            }
        }
        .tint(.accentColor)
        .sheet(
            item: $navigation._sheet,
            onDismiss: navigation._onModalDismiss,
            content: { $0.view }
        )
        .fullScreenCover(
            item: $navigation._fullscreen,
            onDismiss: navigation._onModalDismiss,
            content: { $0.view }
        )
        .environmentObject(navigation)
        .environmentObject(appState)
        .alert(
            appState.error?.localizedDescription ?? "",
            isPresented: Binding(
                get: { appState.error != nil },
                set: { _ in appState.error = nil }
            )
        ) { }
        .alert(
            appState.prompt ?? "",
            isPresented: Binding(
                get: { appState.prompt != nil },
                set: { _ in appState.prompt = nil }
            )
        ) {
        }
    }
}

enum FunnelMinkTab: Int, Identifiable, CaseIterable {
    // The order of the cases determines the order of the tabs
    case today // today at a glance. Todoist
    case contacts // quick find a contact. send invoice. send business card. Apple Contacts
    case funnels // leads and other - Jira
    case inbox // would be really cool to make this its own email client
    case account // settings, profile, etc. Apple Settings
    
    var id: Int {
        rawValue
    }
    
    @ViewBuilder
    var root: some View {
        switch self {
        case .today: TodayView()
        case .contacts: ContactsView()
        case .funnels: FunnelsView()
        case .inbox: InboxView()
        case .account: AccountView()
        }
    }

    @ViewBuilder
    var tabItem: some View {
        switch self {
        case .today: Label("Today", systemImage: "\(String(format: "%02d", Calendar.current.component(.day, from: .init()))).square.fill")
        case .contacts: Label("Contacts", systemImage: "circle.hexagongrid")
        case .funnels: Label("Funnels", image: "funnels.icon")
        case .inbox: Label("Inbox", systemImage: "envelope")
        case .account: Label("Account", systemImage: "person")
        }
    }
}

class FunnelminkApp_Previews: PreviewProvider {
    static var previews: some View {
        FunnelminkAppContents()
    }
    #if DEBUG
    @objc class func injected() {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        windowScene?.windows.first?.rootViewController =
            UIHostingController(rootView: FunnelminkAppContents())
    }
    #endif
}
