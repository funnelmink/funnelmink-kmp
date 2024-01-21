import SwiftUI

struct AccountView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigation: Navigation
    @StateObject var viewModel = AccountViewModel()
    var body: some View {
        List {
            Section {
                Button {
                    // TODO: can edit user's name, email, avatar, etc
                } label: {
                    HStack {
                    VStack(alignment: .leading) {
                        Text("\(appState.user?.username ?? "Your account")")
                            .font(.headline)
                            .fontWeight(.bold)
                            Text("\(appState.user?.email ?? "Workspace settings")")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                        Spacer()
                        chevron
                    }
                }
                Button {
                    navigation.performSegue(.workspaceSettings)
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(appState.workspace?.name ?? "")
                        }
                        Spacer()
                        chevron
                    }
                }
            }
            
            Section(header: Text("Settings (none of these work)")) {
                settingRow(systemIcon: "bell", text: "Notifications")
                settingRow(systemIcon: "lock", text: "Privacy")
                settingRow(systemIcon: "envelope", text: "Email")
                settingRow(systemIcon: "questionmark.circle", text: "Help")
                settingRow(systemIcon: "exclamationmark.circle", text: "Report a problem")
            }
            
            Section {
                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                    infoRow(name: "App version:", value: version)
                }
                infoRow(name: "iOS version:", value: UIDevice.current.systemVersion)
                if let id = appState.user?.id {
                    infoRow(name: "User:", value: id, font: .caption)
                }
                if let id = appState.workspace?.id {
                    infoRow(name: "Workspace:", value: id, font: .caption)
                }
                WarningAlertButton(
                    warningMessage: "Are you sure you want to sign out?",
                    action: {
                        appState.signOut()
                    },
                    label: {
                        Text("Sign out").foregroundStyle(.red)
                    }
                )
            }
        }
        .scrollIndicators(.never)
        .tint(.primary)
        .navigationTitle("Account")
    }
    
    private var chevron: some View {
        Image(systemName: "chevron.right").foregroundColor(.gray)
    }
    
    private func settingRow(systemIcon: String, text: String) -> some View {
        HStack {
            Image(systemName: systemIcon)
            Text(text)
            Spacer()
            chevron
        }
    }
    
    private func infoRow(name: String, value: String, font: Font = .caption2) -> some View {
        // TODO: toast "copied to clipboard"
        Button {
            UIPasteboard.general.string = """
                App version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
                iOS version: \(UIDevice.current.systemVersion)
                User ID: \(appState.user?.id ?? "")
                Workspace ID: \(appState.workspace?.id ?? "")
                """
        } label: {
            HStack {
                Text(name)
                    .font(.caption2)
                Spacer()
                Text(value)
                    .font(font)
            }
        }
    }
}

#Preview {
    AccountView()
        .environmentObject(AppState())
}
